import { getFromCache, saveToCache } from '@/services/cacheService';
import { youtubeApiKey } from '@/config';

export interface VideoData {
  id: string;
  title: string;
  channelName: string;
  publishedAt: string;
  thumbnailUrl: string;
  videoUrl: string;
  tags: string[];
  location?: {
    city?: string;
    country?: string;
    latitude?: number;
    longitude?: number;
  };
  recordingDate?: string;
}

const CHANNEL_IDS = [
  'UCynoa1DjwnvHAowA_jiMEAQ',
  'UCK0KOjX3beyB9nzonls0cuw',
  'UCACkIrvrGAQ7kuc0hMVwvmA',
  'UCtWRAKKvOEA0CXOue9BG8ZA',
];

let lastGeocodeRequest = 0;

async function fetchJson<T>(url: string): Promise<T> {
  const response = await fetch(url);
  if (!response.ok) {
    throw new Error(`Request failed: ${response.status}`);
  }

  return (await response.json()) as T;
}

async function delay(ms: number) {
  return new Promise((resolve) => setTimeout(resolve, ms));
}

async function reverseGeocode(latitude: number, longitude: number) {
  const now = Date.now();
  const waitTime = Math.max(0, 1000 - (now - lastGeocodeRequest));
  if (waitTime > 0) {
    await delay(waitTime);
  }

  lastGeocodeRequest = Date.now();

  const url = `https://nominatim.openstreetmap.org/reverse?format=jsonv2&lat=${latitude}&lon=${longitude}`;
  const response = await fetch(url, {
    headers: {
      'User-Agent': 'YouTube-Video-App/1.0',
    },
  });

  if (!response.ok) {
    return {};
  }

  const payload = (await response.json()) as {
    address?: { city?: string; town?: string; village?: string; country?: string };
  };

  return {
    city: payload.address?.city ?? payload.address?.town ?? payload.address?.village,
    country: payload.address?.country,
  };
}

function formatDate(dateValue?: string) {
  if (!dateValue) {
    return undefined;
  }

  return new Date(dateValue).toISOString().split('T')[0];
}

function parseLocationDescription(description?: string) {
  if (!description) {
    return {};
  }

  const match = description.match(/([A-Za-z\s.'-]+),\s*([A-Za-z\s.'-]+)/);
  if (!match) {
    return {};
  }

  return {
    city: match[1]?.trim(),
    country: match[2]?.trim(),
  };
}

async function fetchChannelVideos(channelId: string): Promise<VideoData[]> {
  const searchUrl =
    `https://www.googleapis.com/youtube/v3/search?part=snippet&channelId=${channelId}` +
    `&order=date&maxResults=50&type=video&key=${youtubeApiKey}`;

  const searchResponse = await fetchJson<{
    items: Array<{
      id?: { videoId?: string };
      snippet?: {
        channelTitle?: string;
        locationDescription?: string;
        publishedAt?: string;
        thumbnails?: { medium?: { url?: string }; default?: { url?: string } };
        title?: string;
      };
    }>;
  }>(searchUrl);

  const videoIds = searchResponse.items
    .map((item) => item.id?.videoId)
    .filter((value): value is string => Boolean(value));

  if (videoIds.length === 0) {
    return [];
  }

  const detailsUrl =
    `https://www.googleapis.com/youtube/v3/videos?part=snippet,recordingDetails,localizations&id=${videoIds.join(',')}` +
    `&key=${youtubeApiKey}`;

  const detailsResponse = await fetchJson<{
    items: Array<{
      id: string;
      recordingDetails?: {
        location?: { latitude?: number; longitude?: number };
        recordingDate?: string;
      };
      snippet?: {
        channelTitle?: string;
        publishedAt?: string;
        tags?: string[];
        thumbnails?: { medium?: { url?: string }; default?: { url?: string } };
        title?: string;
      };
    }>;
  }>(detailsUrl);

  const detailsMap = new Map(detailsResponse.items.map((item) => [item.id, item]));

  const mappedVideos: Array<VideoData | null> = await Promise.all(
    searchResponse.items.map(async (item) => {
      const videoId = item.id?.videoId;
      if (!videoId) {
        return null;
      }

      const details = detailsMap.get(videoId);
      const latitude = details?.recordingDetails?.location?.latitude;
      const longitude = details?.recordingDetails?.location?.longitude;
      const textLocation = parseLocationDescription(item.snippet?.locationDescription);
      const geocodedLocation =
        typeof latitude === 'number' && typeof longitude === 'number'
          ? await reverseGeocode(latitude, longitude)
          : {};

      const video: VideoData = {
        id: videoId,
        title: details?.snippet?.title ?? item.snippet?.title ?? 'Untitled video',
        channelName:
          details?.snippet?.channelTitle ?? item.snippet?.channelTitle ?? 'Unknown channel',
        publishedAt: details?.snippet?.publishedAt ?? item.snippet?.publishedAt ?? new Date().toISOString(),
        thumbnailUrl:
          details?.snippet?.thumbnails?.medium?.url ??
          details?.snippet?.thumbnails?.default?.url ??
          item.snippet?.thumbnails?.medium?.url ??
          item.snippet?.thumbnails?.default?.url ??
          '',
        videoUrl: `https://www.youtube.com/watch?v=${videoId}`,
        tags: details?.snippet?.tags ?? [],
        location:
          typeof latitude === 'number' && typeof longitude === 'number'
            ? {
                latitude,
                longitude,
                city: geocodedLocation.city ?? textLocation.city,
                country: geocodedLocation.country ?? textLocation.country,
              }
            : textLocation.city || textLocation.country
              ? {
                  city: textLocation.city,
                  country: textLocation.country,
                }
              : undefined,
        recordingDate: formatDate(details?.recordingDetails?.recordingDate),
      };

      return video;
    })
  );

  return mappedVideos.filter((item): item is VideoData => item !== null);
}

export async function enhanceLocationData(videos: VideoData[]) {
  return Promise.all(
    videos.map(async (video) => {
      if (
        video.location?.latitude == null ||
        video.location?.longitude == null ||
        (video.location.city && video.location.country)
      ) {
        return video;
      }

      const geocoded = await reverseGeocode(video.location.latitude, video.location.longitude);
      return {
        ...video,
        location: {
          ...video.location,
          city: video.location.city ?? geocoded.city,
          country: video.location.country ?? geocoded.country,
        },
      };
    })
  );
}

export async function fetchAllVideos(forceRefresh = false): Promise<VideoData[]> {
  if (!forceRefresh) {
    const cachedVideos = await getFromCache();
    if (cachedVideos) {
      const enhancedVideos = await enhanceLocationData(cachedVideos);
      await saveToCache(enhancedVideos);
      return enhancedVideos;
    }
  }

  const allVideos = (await Promise.all(CHANNEL_IDS.map((channelId) => fetchChannelVideos(channelId))))
    .flat()
    .sort((left, right) => new Date(right.publishedAt).getTime() - new Date(left.publishedAt).getTime());

  await saveToCache(allVideos);
  return allVideos;
}
