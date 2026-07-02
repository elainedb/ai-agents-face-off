export type ApiConfig = {
  baseUrl: string;
  apiKey: string;
};

type RawThumbnails = {
  medium?: { url: string };
  default?: { url: string };
};

type RawSearchItem = {
  id: { videoId: string };
  snippet: {
    publishedAt: string;
    title: string;
    description: string;
    channelTitle: string;
    thumbnails: RawThumbnails;
  };
};

type RawSearchResponse = {
  items: RawSearchItem[];
  nextPageToken?: string;
};

type RawVideoItem = {
  id: string;
  snippet: {
    publishedAt: string;
    title: string;
    description: string;
    channelTitle: string;
    thumbnails: RawThumbnails;
  };
  recordingDetails?: {
    location?: { latitude: number; longitude: number };
  };
};

type RawVideosResponse = {
  items: RawVideoItem[];
};

async function fetchJson<T>(url: string): Promise<T> {
  const res = await fetch(url);
  if (!res.ok) {
    throw new Error(`YouTube API request failed (${res.status}): ${url}`);
  }
  return (await res.json()) as T;
}

function chunk<T>(arr: T[], size: number): T[][] {
  const out: T[][] = [];
  for (let i = 0; i < arr.length; i += size) {
    out.push(arr.slice(i, i + size));
  }
  return out;
}

/** Follows nextPageToken until exhausted — every page of every channel must be fetched. */
export async function searchAllChannelVideos(
  cfg: ApiConfig,
  channelId: string,
): Promise<RawSearchItem[]> {
  const items: RawSearchItem[] = [];
  let pageToken = '';
  do {
    const params = new URLSearchParams({
      key: cfg.apiKey,
      channelId,
      part: 'snippet',
      order: 'date',
      type: 'video',
      maxResults: '50',
    });
    if (pageToken) params.set('pageToken', pageToken);
    const json = await fetchJson<RawSearchResponse>(
      `${cfg.baseUrl}/youtube/v3/search?${params.toString()}`,
    );
    items.push(...json.items);
    pageToken = json.nextPageToken ?? '';
  } while (pageToken);
  return items;
}

/** videos.list accepts up to 50 ids per call; chunk larger id sets. */
export async function fetchVideoDetails(
  cfg: ApiConfig,
  ids: string[],
): Promise<RawVideoItem[]> {
  const results: RawVideoItem[] = [];
  for (const idChunk of chunk(ids, 50)) {
    if (idChunk.length === 0) continue;
    const params = new URLSearchParams({
      key: cfg.apiKey,
      id: idChunk.join(','),
      part: 'snippet,contentDetails,recordingDetails',
    });
    const json = await fetchJson<RawVideosResponse>(
      `${cfg.baseUrl}/youtube/v3/videos?${params.toString()}`,
    );
    results.push(...json.items);
  }
  return results;
}

export type { RawSearchItem, RawVideoItem };
