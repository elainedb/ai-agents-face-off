import Constants from 'expo-constants';

export type YoutubeVideo = {
  id: string;
  title: string;
  channelTitle: string;
  publishedAt: string; // ISO string
  thumbnailUrl: string;
};

const API_BASE = 'https://www.googleapis.com/youtube/v3';

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

async function fetchChannelLatestVideos(channelId: string, maxResults = 10): Promise<YoutubeVideo[]> {
  const params = new URLSearchParams({
    key: getYoutubeApiKey(),
    part: 'snippet',
    channelId,
    order: 'date',
    maxResults: String(maxResults),
    type: 'video',
  });

  const url = `${API_BASE}/search?${params.toString()}`;
  const res = await fetch(url);
  if (!res.ok) {
    const text = await res.text();
    throw new Error(`YouTube API error (${res.status}): ${text}`);
  }
  const json = await res.json();

  const items: YoutubeVideo[] = (json.items || []).map((item: any) => {
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
  }).filter((v: YoutubeVideo) => !!v.id);

  return items;
}

export async function fetchCombinedChannelVideos(channelIds: string[], perChannel = 10): Promise<YoutubeVideo[]> {
  const lists = await Promise.all(channelIds.map((id) => fetchChannelLatestVideos(id, perChannel)));
  const combined = lists.flat();
  combined.sort((a, b) => (new Date(b.publishedAt).getTime()) - (new Date(a.publishedAt).getTime()));
  return combined;
}

export function formatDateYYYYMMDD(iso: string): string {
  if (!iso) return '';
  try {
    return new Date(iso).toISOString().slice(0, 10);
  } catch {
    return iso;
  }
}
