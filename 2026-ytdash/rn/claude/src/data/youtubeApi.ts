import { SourceChannel } from './channels';

export type VideoStub = {
  id: string;
  title: string;
  description: string;
  publishedAt: string;
  category: string; // the source channel's configured label — NOT the API's channelTitle
  thumbnailUrl: string;
};

type SearchListItem = {
  id: { videoId: string };
  snippet: {
    publishedAt: string;
    title: string;
    description: string;
    thumbnails?: { medium?: { url: string }; default?: { url: string } };
  };
};

type SearchListResponse = {
  nextPageToken?: string;
  items: SearchListItem[];
};

type VideosListItem = {
  id: string;
  recordingDetails?: { location?: { latitude: number; longitude: number } };
};

type VideosListResponse = {
  items: VideosListItem[];
};

function buildUrl(baseUrl: string, endpoint: string, params: Record<string, string>): string {
  const url = new URL(`/youtube/v3/${endpoint}`, baseUrl);
  for (const [key, value] of Object.entries(params)) {
    url.searchParams.set(key, value);
  }
  return url.toString();
}

async function getJson<T>(url: string): Promise<T> {
  const response = await fetch(url);
  if (!response.ok) {
    throw new Error(`YouTube API request failed (${response.status}): ${url}`);
  }
  return (await response.json()) as T;
}

// Follows `nextPageToken` until exhausted — every configured channel's FULL video set, not just
// page 1 (spec.md Iteration 2 / AC-COUNT-01). There is no catch-all query; this must be called
// once per configured channel.
export async function fetchChannelVideos(baseUrl: string, apiKey: string, channel: SourceChannel): Promise<VideoStub[]> {
  const out: VideoStub[] = [];
  let pageToken: string | undefined;

  do {
    const url = buildUrl(baseUrl, 'search', {
      key: apiKey,
      channelId: channel.id,
      part: 'snippet',
      order: 'date',
      type: 'video',
      maxResults: '50',
      ...(pageToken ? { pageToken } : {}),
    });
    const page = await getJson<SearchListResponse>(url);

    for (const item of page.items) {
      out.push({
        id: item.id.videoId,
        title: item.snippet.title,
        description: item.snippet.description,
        publishedAt: item.snippet.publishedAt,
        category: channel.label,
        thumbnailUrl: item.snippet.thumbnails?.medium?.url ?? item.snippet.thumbnails?.default?.url ?? '',
      });
    }

    pageToken = page.nextPageToken;
  } while (pageToken);

  return out;
}

// Location lives only in videos.list's recordingDetails (youtube-api.md §2). Batches ≤50 ids per
// call, per the real API's limit.
export async function fetchVideoLocations(baseUrl: string, apiKey: string, ids: string[]): Promise<Map<string, { lat: number; lng: number }>> {
  const locations = new Map<string, { lat: number; lng: number }>();
  const batchSize = 50;

  for (let i = 0; i < ids.length; i += batchSize) {
    const batch = ids.slice(i, i + batchSize);
    if (batch.length === 0) continue;
    const url = buildUrl(baseUrl, 'videos', {
      key: apiKey,
      id: batch.join(','),
      part: 'snippet,contentDetails,recordingDetails',
    });
    const page = await getJson<VideosListResponse>(url);
    for (const item of page.items) {
      const loc = item.recordingDetails?.location;
      if (loc) {
        locations.set(item.id, { lat: loc.latitude, lng: loc.longitude });
      }
    }
  }

  return locations;
}
