import type { SourceChannel, Video } from '../domain/models';

type SearchSnippet = {
  publishedAt: string;
  title: string;
  description: string;
  thumbnails?: { medium?: { url: string }; default?: { url: string } };
};

type SearchItem = {
  id: { videoId: string };
  snippet: SearchSnippet;
};

type SearchListResponse = {
  items: SearchItem[];
  nextPageToken?: string;
};

type VideosListItem = {
  id: string;
  recordingDetails?: { location?: { latitude: number; longitude: number } };
};

type VideosListResponse = {
  items: VideosListItem[];
};

function buildUrl(baseUrl: string, path: string, params: Record<string, string>): string {
  const url = new URL(`${baseUrl.replace(/\/$/, '')}/youtube/v3/${path}`);
  for (const [k, v] of Object.entries(params)) url.searchParams.set(k, v);
  return url.toString();
}

async function getJson<T>(url: string): Promise<T> {
  const res = await fetch(url);
  if (!res.ok) {
    throw new Error(`YouTube API request failed: ${res.status} ${res.statusText}`);
  }
  return (await res.json()) as T;
}

async function fetchAllPagesForChannel(
  baseUrl: string,
  apiKey: string,
  channel: SourceChannel,
): Promise<Array<{ id: string; snippet: SearchSnippet; category: string }>> {
  const out: Array<{ id: string; snippet: SearchSnippet; category: string }> = [];
  let pageToken: string | undefined;
  do {
    const params: Record<string, string> = {
      key: apiKey,
      channelId: channel.id,
      part: 'snippet',
      order: 'date',
      type: 'video',
      maxResults: '50',
    };
    if (pageToken) params.pageToken = pageToken;
    const url = buildUrl(baseUrl, 'search', params);
    const page = await getJson<SearchListResponse>(url);
    for (const item of page.items ?? []) {
      out.push({ id: item.id.videoId, snippet: item.snippet, category: channel.label });
    }
    pageToken = page.nextPageToken;
  } while (pageToken);
  return out;
}

async function fetchLocations(baseUrl: string, apiKey: string, ids: string[]): Promise<Map<string, { lat: number; lng: number }>> {
  const result = new Map<string, { lat: number; lng: number }>();
  const chunkSize = 50;
  for (let i = 0; i < ids.length; i += chunkSize) {
    const chunk = ids.slice(i, i + chunkSize);
    if (chunk.length === 0) continue;
    const url = buildUrl(baseUrl, 'videos', {
      key: apiKey,
      id: chunk.join(','),
      part: 'snippet,contentDetails,recordingDetails',
    });
    const res = await getJson<VideosListResponse>(url);
    for (const item of res.items ?? []) {
      const loc = item.recordingDetails?.location;
      if (loc) result.set(item.id, { lat: loc.latitude, lng: loc.longitude });
    }
  }
  return result;
}

export async function fetchAllVideos(channels: SourceChannel[], baseUrl: string, apiKey: string): Promise<Video[]> {
  const merged = new Map<string, { id: string; snippet: SearchSnippet; category: string }>();

  for (const channel of channels) {
    const items = await fetchAllPagesForChannel(baseUrl, apiKey, channel);
    for (const item of items) {
      if (!merged.has(item.id)) merged.set(item.id, item);
    }
  }

  const ids = Array.from(merged.keys());
  const locations = await fetchLocations(baseUrl, apiKey, ids);

  const videos: Video[] = ids.map((id) => {
    const entry = merged.get(id)!;
    const loc = locations.get(id) ?? null;
    const thumbnailUrl = entry.snippet.thumbnails?.medium?.url ?? entry.snippet.thumbnails?.default?.url ?? '';
    return {
      id,
      title: entry.snippet.title,
      description: entry.snippet.description,
      publishedAt: entry.snippet.publishedAt,
      category: entry.category,
      thumbnailUrl,
      youtubeUrl: `https://www.youtube.com/watch?v=${id}`,
      lat: loc?.lat ?? null,
      lng: loc?.lng ?? null,
    };
  });

  return videos;
}
