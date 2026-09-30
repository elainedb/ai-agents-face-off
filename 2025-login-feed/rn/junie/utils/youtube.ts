import Constants from 'expo-constants';

// Extended video type for v3 requirements
export type YoutubeVideo = {
  id: string;
  title: string;
  channelTitle: string;
  publishedAt: string; // ISO string
  thumbnailUrl: string;
  // v3 additions
  tags?: string[];
  recordingDate?: string; // ISO date string
  locationCity?: string;
  locationCountry?: string;
  locationLat?: number;
  locationLng?: number;
};

const API_BASE = 'https://www.googleapis.com/youtube/v3';
const CACHE_KEY_PREFIX = 'videoCache_v3';
const CACHE_TTL_MS = 24 * 60 * 60 * 1000; // 24 hours

// Reverse geocoding cache (longer TTL since city/country rarely change)
const GEOCODE_CACHE_PREFIX = 'geocodeCache_v1';
const GEOCODE_TTL_MS = 30 * 24 * 60 * 60 * 1000; // 30 days

// Lazy AsyncStorage import to avoid hard dependency if not installed
let AsyncStorage: any | null = null;
try {
  // eslint-disable-next-line @typescript-eslint/no-var-requires
  AsyncStorage = require('@react-native-async-storage/async-storage');
} catch {
  AsyncStorage = null;
}

function getYoutubeApiKey(): string {
  const fromExtra = (Constants.expoConfig as any)?.extra?.youtubeApiKey as string | undefined;
  const fromEnv = (process.env as any)?.EXPO_PUBLIC_YOUTUBE_API_KEY as string | undefined;
  const key = fromExtra || fromEnv;
  if (!key) {
    const srcExtra = (Constants.expoConfig as any)?.extra?.__youtubeApiKeySource;
    throw new Error(
      `YouTube API key not configured. Set EXPO_PUBLIC_YOUTUBE_API_KEY in your environment or add a config.js with export const youtubeApiKey = "..." (loaded via app.config.js). Current source: ${srcExtra || 'none'}`
    );
  }
  return key;
}

// Helper: read and write generic cache blobs
async function readCache(key: string): Promise<{ ts: number; data: any } | null> {
  if (!AsyncStorage) return null;
  try {
    const raw = await AsyncStorage.getItem(key);
    if (!raw) return null;
    const parsed = JSON.parse(raw);
    if (parsed && parsed.hasOwnProperty('data')) return parsed;
  } catch {
    // ignore
  }
  return null;
}

async function writeCache(key: string, value: { ts: number; data: any }): Promise<void> {
  if (!AsyncStorage) return;
  try {
    await AsyncStorage.setItem(key, JSON.stringify(value));
  } catch {
    // ignore
  }
}

// Reverse geocoding using OpenStreetMap Nominatim (no API key). Polite usage + caching.
async function reverseGeocodeCityCountry(lat: number, lng: number): Promise<{ city?: string; country?: string } | null> {
  const rounded = (n: number) => Math.round(n * 1e5) / 1e5; // normalize to reduce cache keys
  const key = `${GEOCODE_CACHE_PREFIX}:${rounded(lat)},${rounded(lng)}`;
  const cached = await readCache(key);
  if (cached && Date.now() - cached.ts < GEOCODE_TTL_MS) {
    const data = cached.data || {};
    return { city: data.city, country: data.country };
  }

  try {
    const url = `https://nominatim.openstreetmap.org/reverse?format=jsonv2&lat=${encodeURIComponent(lat)}&lon=${encodeURIComponent(lng)}&zoom=10&addressdetails=1`;
    const res = await fetch(url, {
      headers: {
        'User-Agent': 'rn_junie/1.0 (reverse-geocode)'
      },
    });
    if (!res.ok) {
      // Do not throw; just fail gracefully
      return null;
    }
    const json = await res.json();
    const addr = json?.address || {};
    const city = addr.city || addr.town || addr.village || addr.hamlet || addr.municipality || undefined;
    const country = addr.country || undefined;
    const result = { city, country };
    await writeCache(key, { ts: Date.now(), data: result });
    return result;
  } catch {
    return null;
  }
}

// Search latest videos for a channel and return basic info (including IDs)
async function fetchChannelLatestVideosBasic(channelId: string, maxResults = 10): Promise<YoutubeVideo[]> {
  // YouTube search API returns up to 50 items per request. Implement pagination
  // to collect up to maxResults items or until there are no more pages.
  const cap = Math.max(1, Math.min(Number.isFinite(maxResults) ? maxResults : 50, 500)); // safety cap
  let collected: YoutubeVideo[] = [];
  let pageToken: string | undefined = undefined;

  while (collected.length < cap) {
    const remaining = cap - collected.length;
    const perPage = Math.min(remaining, 50);
    const params = new URLSearchParams({
      key: getYoutubeApiKey(),
      part: 'snippet',
      channelId,
      order: 'date',
      maxResults: String(perPage),
      type: 'video',
    });
    if (pageToken) params.set('pageToken', pageToken);

    const url = `${API_BASE}/search?${params.toString()}`;
    const res = await fetch(url);
    if (!res.ok) {
      const text = await res.text();
      throw new Error(`YouTube API error (${res.status}): ${text}`);
    }
    const json = await res.json();

    const pageItems: YoutubeVideo[] = (json.items || [])
      .map((item: any) => {
        const id = item.id?.videoId ?? '';
        const sn = item.snippet || {};
        const thumbs = sn.thumbnails || {};
        const thumb = thumbs.high?.url || thumbs.medium?.url || thumbs.default?.url || '';
        return {
          id,
          title: sn.title || '',
          channelTitle: sn.channelTitle || '',
          publishedAt: sn.publishedAt || '',
          thumbnailUrl: thumb,
        } as YoutubeVideo;
      })
      .filter((v: YoutubeVideo) => !!v.id);

    collected = collected.concat(pageItems);

    pageToken = json.nextPageToken;
    if (!pageToken) break;
  }

  // Trim in case we fetched slightly more on the last page
  return collected.slice(0, cap);
}

// Fetch detailed information for a list of video IDs
async function fetchVideoDetails(ids: string[]): Promise<Partial<YoutubeVideo>[]> {
  if (ids.length === 0) return [];
  const idBatches: string[][] = [];
  for (let i = 0; i < ids.length; i += 50) {
    idBatches.push(ids.slice(i, i + 50));
  }

  const results: Partial<YoutubeVideo>[] = [];
  for (const batch of idBatches) {
    const params = new URLSearchParams({
      key: getYoutubeApiKey(),
      id: batch.join(','),
      part: 'snippet,recordingDetails',
    });
    const url = `${API_BASE}/videos?${params.toString()}`;
    const res = await fetch(url);
    if (!res.ok) {
      const text = await res.text();
      throw new Error(`YouTube API error (${res.status}): ${text}`);
    }
    const json = await res.json();
    for (const item of json.items || []) {
      const sn = item.snippet || {};
      const rd = item.recordingDetails || {};
      const loc = rd.location || {};
      const details: Partial<YoutubeVideo> = {
        id: item.id,
        // tags
        tags: Array.isArray(sn.tags) ? sn.tags : undefined,
        // recording date may be like 2015-08-25
        recordingDate: rd.recordingDate || undefined,
        // naive parsing: try to split locationDescription into parts "City, Country"
        locationCity: undefined,
        locationCountry: undefined,
        locationLat: typeof loc.latitude === 'number' ? loc.latitude : undefined,
        locationLng: typeof loc.longitude === 'number' ? loc.longitude : undefined,
      };
      if (sn?.defaultAudioLanguage && !sn.defaultLanguage) {
        // no-op but placeholder in case needed later
      }
      // Only use recordingDetails.locationDescription for human-readable location; do not fall back to video description
      const desc = typeof rd.locationDescription === 'string' ? rd.locationDescription : '';
      if (desc.trim().length > 0) {
        const parts = desc.split(',').map((s: string) => s.trim()).filter(Boolean);
        if (parts.length >= 2) {
          details.locationCity = details.locationCity || parts[0];
          details.locationCountry = details.locationCountry || parts[parts.length - 1];
        }
      }

      // Reverse geocode if we have coordinates but missing city/country
      if ((details.locationCity == null || details.locationCountry == null) &&
          typeof details.locationLat === 'number' && typeof details.locationLng === 'number') {
        try {
          const geo = await reverseGeocodeCityCountry(details.locationLat, details.locationLng);
          if (geo) {
            details.locationCity = details.locationCity || geo.city;
            details.locationCountry = details.locationCountry || geo.country;
          }
        } catch {
          // ignore reverse geocode failures
        }
      }

      results.push(details);
    }
  }
  return results;
}

export async function fetchCombinedChannelVideos(channelIds: string[], perChannel = 10): Promise<YoutubeVideo[]> {
  const lists = await Promise.all(channelIds.map((id) => fetchChannelLatestVideosBasic(id, perChannel)));
  const combinedBasic = lists.flat();
  const ids = combinedBasic.map((v) => v.id);
  const details = await fetchVideoDetails(ids);
  const detailsMap = new Map(details.map((d) => [d.id as string, d]));
  const merged = combinedBasic.map((b) => ({ ...b, ...(detailsMap.get(b.id) || {}) } as YoutubeVideo));
  merged.sort((a, b) => new Date(b.publishedAt).getTime() - new Date(a.publishedAt).getTime());
  return merged;
}

export async function fetchCombinedChannelVideosCached(
  channelIds: string[],
  perChannel = 10,
  opts: { forceRefresh?: boolean } = {}
): Promise<YoutubeVideo[]> {
  const key = `${CACHE_KEY_PREFIX}:${channelIds.join(',')}:${perChannel}`;
  if (!opts.forceRefresh) {
    const cached = await readCache(key);
    if (cached && Date.now() - cached.ts < CACHE_TTL_MS) {
      return cached.data as YoutubeVideo[];
    }
  }
  const fresh = await fetchCombinedChannelVideos(channelIds, perChannel);
  await writeCache(key, { ts: Date.now(), data: fresh });
  return fresh;
}

export function formatDateYYYYMMDD(iso: string): string {
  if (!iso) return '';
  try {
    return new Date(iso).toISOString().slice(0, 10);
  } catch {
    return iso;
  }
}
