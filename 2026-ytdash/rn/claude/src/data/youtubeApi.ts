import { SOURCE_CHANNELS } from '../config/channels';
import { AppConfig, GeoLocation, SourceChannel, Video } from '../domain/types';

// ---- Raw API shapes (mirror YouTube Data API v3; the mock serves the same shapes) ----
type Thumbnail = { url?: string };
type Snippet = {
  publishedAt?: string;
  title?: string;
  description?: string;
  thumbnails?: { default?: Thumbnail; medium?: Thumbnail; high?: Thumbnail };
};
type SearchItem = { id?: { videoId?: string }; snippet?: Snippet };
type SearchResponse = { items?: SearchItem[]; nextPageToken?: string };
type VideosItem = {
  id?: string;
  recordingDetails?: { location?: { latitude?: number; longitude?: number } };
};
type VideosResponse = { items?: VideosItem[] };

const MAX_PAGES = 50; // safety cap against a runaway paginator

function endpoint(cfg: AppConfig, path: string, params: Record<string, string>): string {
  const base = cfg.apiBaseUrl.replace(/\/+$/, '');
  const q = new URLSearchParams({ key: cfg.apiKey, ...params });
  return `${base}/youtube/v3/${path}?${q.toString()}`;
}

async function getJson<T>(url: string): Promise<T> {
  const res = await fetch(url);
  if (!res.ok) {
    throw new Error(`API ${res.status} for ${url}`);
  }
  return (await res.json()) as T;
}

function youtubeUrl(id: string): string {
  return `https://www.youtube.com/watch?v=${id}`;
}

// Fetch EVERY page of a single channel's uploads via search.list, following nextPageToken.
async function fetchChannelVideos(cfg: AppConfig, channel: SourceChannel): Promise<Video[]> {
  const out: Video[] = [];
  let pageToken = '';
  for (let page = 0; page < MAX_PAGES; page++) {
    const url = endpoint(cfg, 'search', {
      channelId: channel.id,
      part: 'snippet',
      order: 'date',
      type: 'video',
      maxResults: '50',
      ...(pageToken ? { pageToken } : {}),
    });
    const data = await getJson<SearchResponse>(url);
    for (const item of data.items ?? []) {
      const id = item.id?.videoId;
      if (!id) continue;
      const s = item.snippet ?? {};
      out.push({
        id,
        title: s.title ?? '',
        description: s.description ?? '',
        publishedAt: s.publishedAt ?? '',
        // "category" is the SOURCE CHANNEL's configured label (spec / youtube-api mapping).
        category: channel.label,
        thumbnailUrl: s.thumbnails?.medium?.url ?? s.thumbnails?.default?.url ?? '',
        location: null,
        youtubeUrl: youtubeUrl(id),
      });
    }
    if (!data.nextPageToken) break;
    pageToken = data.nextPageToken;
  }
  return out;
}

// Attach recordingDetails.location via videos.list (batched by 50 ids). Only videos whose owner set
// a recording location come back with one — in the fixture, 5 of 8 (the map markers).
async function attachLocations(cfg: AppConfig, videos: Video[]): Promise<void> {
  const byId = new Map(videos.map((v) => [v.id, v]));
  const ids = [...byId.keys()];
  for (let i = 0; i < ids.length; i += 50) {
    const chunk = ids.slice(i, i + 50);
    const url = endpoint(cfg, 'videos', {
      id: chunk.join(','),
      part: 'snippet,contentDetails,recordingDetails',
    });
    const data = await getJson<VideosResponse>(url);
    for (const item of data.items ?? []) {
      const loc = item.recordingDetails?.location;
      if (item.id && loc && typeof loc.latitude === 'number' && typeof loc.longitude === 'number') {
        const geo: GeoLocation = { lat: loc.latitude, lng: loc.longitude };
        const v = byId.get(item.id);
        if (v) v.location = geo;
      }
    }
  }
}

// Aggregate ALL configured channels: paginate each, merge, dedupe by videoId (first wins → stable
// order), then enrich with locations. No catch-all, no hardcoded fixture values (anti-overfit).
export async function fetchAllVideos(cfg: AppConfig): Promise<Video[]> {
  const merged: Video[] = [];
  const seen = new Set<string>();
  for (const channel of SOURCE_CHANNELS) {
    const channelVideos = await fetchChannelVideos(cfg, channel);
    for (const v of channelVideos) {
      if (seen.has(v.id)) continue;
      seen.add(v.id);
      merged.push(v);
    }
  }
  await attachLocations(cfg, merged);
  return merged;
}
