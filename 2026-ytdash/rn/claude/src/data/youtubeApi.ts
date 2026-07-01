import { AppConfig } from '../appConfig';
import { SOURCE_CHANNELS, SourceChannel } from '../channels';
import { Video, watchUrl } from '../domain/models';

// YouTube-Data-API-v3 client. Aggregates the configured source channels, following pagination to
// the last page of every channel, dedupes by videoId, then enriches with recording locations via
// videos.list. There is NO catch-all endpoint (spec/youtube-api.md) — we iterate channels.

const MAX_PAGES_PER_CHANNEL = 50; // safety bound against a misbehaving pagination cursor

async function fetchJson(url: string): Promise<any> {
  const res = await fetch(url);
  if (!res.ok) {
    throw new Error(`HTTP ${res.status} for ${url}`);
  }
  return res.json();
}

function api(cfg: AppConfig, endpoint: string, params: Record<string, string>): string {
  const qs = new URLSearchParams();
  if (cfg.apiKey) qs.set('key', cfg.apiKey);
  for (const [k, v] of Object.entries(params)) {
    if (v !== undefined && v !== null && v !== '') qs.set(k, v);
  }
  // apiBaseUrl is the host root; we append /youtube/v3 ourselves (spec/youtube-api.md).
  return `${cfg.apiBaseUrl.replace(/\/$/, '')}/youtube/v3/${endpoint}?${qs.toString()}`;
}

// One channel's uploads, across all pages. Category is the channel's configured label.
async function fetchChannelVideos(cfg: AppConfig, channel: SourceChannel): Promise<Video[]> {
  const out: Video[] = [];
  let pageToken = '';
  const seenTokens = new Set<string>();
  for (let page = 0; page < MAX_PAGES_PER_CHANNEL; page++) {
    const url = api(cfg, 'search', {
      channelId: channel.id,
      part: 'snippet',
      order: 'date',
      type: 'video',
      maxResults: '50',
      pageToken,
    });
    const data = await fetchJson(url);
    for (const item of data.items ?? []) {
      const id = item?.id?.videoId;
      if (!id) continue;
      const s = item.snippet ?? {};
      out.push({
        id,
        title: s.title ?? '',
        description: s.description ?? '',
        publishedAt: s.publishedAt ?? '',
        category: channel.label,
        thumbnailUrl: s.thumbnails?.medium?.url ?? s.thumbnails?.default?.url ?? null,
        location: null,
        youtubeUrl: watchUrl(id),
      });
    }
    const next = data.nextPageToken ?? '';
    if (!next || seenTokens.has(next)) break;
    seenTokens.add(next);
    pageToken = next;
  }
  return out;
}

function chunk<T>(arr: T[], size: number): T[][] {
  const out: T[][] = [];
  for (let i = 0; i < arr.length; i += size) out.push(arr.slice(i, i + size));
  return out;
}

// Enrich videos with recordingDetails.location (only set for videos whose owner recorded one).
async function enrichLocations(cfg: AppConfig, byId: Map<string, Video>): Promise<void> {
  const ids = [...byId.keys()];
  for (const ids50 of chunk(ids, 50)) {
    const url = api(cfg, 'videos', {
      id: ids50.join(','),
      part: 'snippet,contentDetails,recordingDetails',
    });
    let data: any;
    try {
      data = await fetchJson(url);
    } catch {
      // Location is non-essential; a failure here must not sink the whole list.
      continue;
    }
    for (const item of data.items ?? []) {
      const loc = item?.recordingDetails?.location;
      const v = byId.get(item?.id);
      if (v && loc && typeof loc.latitude === 'number' && typeof loc.longitude === 'number') {
        v.location = { lat: loc.latitude, lng: loc.longitude };
      }
    }
  }
}

export async function fetchAllVideos(cfg: AppConfig): Promise<Video[]> {
  const byId = new Map<string, Video>();
  for (const channel of SOURCE_CHANNELS) {
    const vids = await fetchChannelVideos(cfg, channel);
    for (const v of vids) {
      if (!byId.has(v.id)) byId.set(v.id, v); // dedupe by videoId, preserve first-seen order
    }
  }
  await enrichLocations(cfg, byId);
  return [...byId.values()];
}
