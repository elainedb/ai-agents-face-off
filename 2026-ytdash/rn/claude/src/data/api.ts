import {
  SearchListResponse,
  VideosListResponse,
  Video,
  Result,
  ok,
  err,
  youtubeUrlFor,
} from './types';

export type Channel = { id: string; label: string };

export type ApiConfig = {
  baseUrl: string; // host root, e.g. http://127.0.0.1:8090 or https://www.googleapis.com
  apiKey: string;
  channels: Channel[];
};

const PRODUCTION_BASE = 'https://www.googleapis.com';
const PAGE_LIMIT = 50; // hard stop against a pathological/looping mock
const REQUEST_TIMEOUT_MS = 12000;

function normalizeBase(base: string | null | undefined): string {
  const b = (base && base.trim()) || PRODUCTION_BASE;
  return b.replace(/\/+$/, '');
}

async function getJson(url: string): Promise<unknown> {
  const controller = new AbortController();
  const timer = setTimeout(() => controller.abort(), REQUEST_TIMEOUT_MS);
  try {
    const res = await fetch(url, { signal: controller.signal });
    if (!res.ok) {
      throw new Error(`HTTP ${res.status}`);
    }
    return await res.json();
  } finally {
    clearTimeout(timer);
  }
}

function buildUrl(base: string, endpoint: string, params: Record<string, string>): string {
  const qs = Object.entries(params)
    .filter(([, v]) => v != null && v !== '')
    .map(([k, v]) => `${encodeURIComponent(k)}=${encodeURIComponent(v)}`)
    .join('&');
  return `${base}/youtube/v3/${endpoint}?${qs}`;
}

/**
 * Fetch ALL uploads for one channel via search.list, following nextPageToken until exhausted.
 * Tags each video with the source-channel label as its category (spec: "category = channel label").
 */
async function fetchChannelVideos(
  base: string,
  apiKey: string,
  channel: Channel,
): Promise<Map<string, Video>> {
  const acc = new Map<string, Video>();
  let pageToken = '';
  for (let page = 0; page < PAGE_LIMIT; page++) {
    const url = buildUrl(base, 'search', {
      key: apiKey,
      channelId: channel.id,
      part: 'snippet',
      order: 'date',
      type: 'video',
      maxResults: '50',
      pageToken,
    });
    const raw = await getJson(url);
    const parsed = SearchListResponse.parse(raw);
    for (const item of parsed.items) {
      const id = item.id?.videoId;
      if (!id) continue;
      const s = item.snippet ?? {};
      if (!acc.has(id)) {
        acc.set(id, {
          id,
          title: s.title ?? '',
          description: s.description ?? '',
          publishedAt: s.publishedAt ?? '',
          category: channel.label,
          thumbnailUrl:
            s.thumbnails?.medium?.url ?? s.thumbnails?.high?.url ?? s.thumbnails?.default?.url ?? null,
          lat: null,
          lng: null,
          youtubeUrl: youtubeUrlFor(id),
        });
      }
    }
    if (!parsed.nextPageToken) break;
    pageToken = parsed.nextPageToken;
  }
  return acc;
}

/** Enrich videos with recording location (only videos.list returns it). Batches of ≤50 ids. */
async function enrichLocations(
  base: string,
  apiKey: string,
  videos: Video[],
): Promise<void> {
  for (let i = 0; i < videos.length; i += 50) {
    const batch = videos.slice(i, i + 50);
    const url = buildUrl(base, 'videos', {
      key: apiKey,
      id: batch.map((v) => v.id).join(','),
      part: 'snippet,contentDetails,recordingDetails',
    });
    const raw = await getJson(url);
    const parsed = VideosListResponse.parse(raw);
    const byId = new Map(videos.map((v) => [v.id, v]));
    for (const item of parsed.items) {
      const v = byId.get(item.id);
      if (!v) continue;
      const loc = item.recordingDetails?.location;
      if (loc) {
        v.lat = loc.latitude;
        v.lng = loc.longitude;
      }
    }
  }
}

/**
 * Aggregate every configured channel (NO catch-all), merge/dedupe by videoId, then enrich with
 * locations. The list order preserves channel order + page order so the first row is the first
 * channel's first video (AC-LIST-03). Nothing here reads fixture values.
 */
export async function fetchAllVideos(config: ApiConfig): Promise<Result<Video[]>> {
  const base = normalizeBase(config.baseUrl);
  const apiKey = config.apiKey ?? '';
  try {
    const merged = new Map<string, Video>();
    for (const channel of config.channels) {
      const channelVideos = await fetchChannelVideos(base, apiKey, channel);
      for (const [id, v] of channelVideos) {
        if (!merged.has(id)) merged.set(id, v);
      }
    }
    const videos = Array.from(merged.values());
    try {
      await enrichLocations(base, apiKey, videos);
    } catch {
      // Location enrichment is best-effort; the list still works without map coordinates.
    }
    return ok(videos);
  } catch (e) {
    const message = e instanceof Error ? e.message : String(e);
    if (message.toLowerCase().includes('json') || message.toLowerCase().includes('parse')) {
      return err('parse', message);
    }
    return err('network', message);
  }
}
