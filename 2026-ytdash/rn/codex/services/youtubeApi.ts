import {
  clearCache,
  getFromCache,
  saveToCache,
} from '@/services/cacheService';
import type { VideoData, VideoLocation } from '@/types/video';

const CHANNEL_IDS = [
  'UCynoa1DjwnvHAowA_jiMEAQ',
  'UCK0KOjX3beyB9nzonls0cuw',
  'UCACkIrvrGAQ7kuc0hMVwvmA',
  'UCtWRAKKvOEA0CXOue9BG8ZA',
];

// eslint-disable-next-line @typescript-eslint/no-require-imports
const { youtubeApiKey } = require('@/config.js') as { youtubeApiKey: string };

type SearchResponse = {
  items?: Array<{
    id?: { videoId?: string };
    snippet?: {
      title?: string;
      channelTitle?: string;
      publishedAt?: string;
      thumbnails?: {
        medium?: { url?: string };
        default?: { url?: string };
      };
    };
  }>;
};

type VideosResponse = {
  items?: Array<{
    id?: string;
    snippet?: {
      title?: string;
      channelTitle?: string;
      publishedAt?: string;
      tags?: string[];
      thumbnails?: {
        medium?: { url?: string };
        default?: { url?: string };
      };
      localizations?: Record<string, unknown>;
      locationDescription?: string;
    };
    recordingDetails?: {
      recordingDate?: string;
      location?: {
        latitude?: number;
        longitude?: number;
      };
      locationDescription?: string;
    };
    localizations?: Record<string, unknown>;
  }>;
};

type RecordingDetails = {
  recordingDate?: string;
  location?: {
    latitude?: number;
    longitude?: number;
  };
  locationDescription?: string;
};

let reverseGeocodeQueue = Promise.resolve();

export async function fetchAllVideos(forceRefresh = false): Promise<VideoData[]> {
  if (forceRefresh) {
    await clearCache();
  } else {
    const cached = await getFromCache();
    if (cached) {
      const enhancedVideos = await enhanceLocationData(cached.videos);
      if (enhancedVideos !== cached.videos) {
        await saveToCache(enhancedVideos);
      }
      return enhancedVideos;
    }
  }

  const videoGroups = await Promise.all(CHANNEL_IDS.map((channelId) => fetchChannelVideos(channelId)));
  const videos = videoGroups
    .flat()
    .sort((left, right) => right.publishedAt.localeCompare(left.publishedAt));

  await saveToCache(videos);
  return videos;
}

async function fetchChannelVideos(channelId: string): Promise<VideoData[]> {
  const searchUrl = new URL('https://www.googleapis.com/youtube/v3/search');
  searchUrl.searchParams.set('part', 'snippet');
  searchUrl.searchParams.set('channelId', channelId);
  searchUrl.searchParams.set('order', 'date');
  searchUrl.searchParams.set('maxResults', '50');
  searchUrl.searchParams.set('type', 'video');
  searchUrl.searchParams.set('key', youtubeApiKey);

  const searchResponse = await fetch(searchUrl.toString());
  if (!searchResponse.ok) {
    throw new Error(`YouTube search request failed for channel ${channelId}.`);
  }

  const searchData = (await searchResponse.json()) as SearchResponse;
  const videoIds = searchData.items
    ?.map((item) => item.id?.videoId)
    .filter((videoId): videoId is string => !!videoId) ?? [];

  if (!videoIds.length) {
    return [];
  }

  const detailsUrl = new URL('https://www.googleapis.com/youtube/v3/videos');
  detailsUrl.searchParams.set('part', 'snippet,recordingDetails,localizations');
  detailsUrl.searchParams.set('id', videoIds.join(','));
  detailsUrl.searchParams.set('key', youtubeApiKey);

  const detailsResponse = await fetch(detailsUrl.toString());
  if (!detailsResponse.ok) {
    throw new Error(`YouTube details request failed for channel ${channelId}.`);
  }

  const detailsData = (await detailsResponse.json()) as VideosResponse;
  const detailsById = new Map(detailsData.items?.map((item) => [item.id, item]) ?? []);

  const videos = await Promise.all(
    videoIds.map(async (videoId) => {
      const detail = detailsById.get(videoId);
      const snippet = detail?.snippet;
      const recordingDetails = detail?.recordingDetails;
      const thumbnailUrl =
        snippet?.thumbnails?.medium?.url ??
        snippet?.thumbnails?.default?.url ??
        `https://i.ytimg.com/vi/${videoId}/mqdefault.jpg`;

      const location = await extractLocation({
        recordingDetails,
        locationDescription:
          recordingDetails?.locationDescription ?? snippet?.locationDescription ?? null,
      });

      return {
        id: videoId,
        title: snippet?.title ?? 'Untitled video',
        channelName: snippet?.channelTitle ?? 'Unknown channel',
        publishedAt: snippet?.publishedAt ?? new Date().toISOString(),
        thumbnailUrl,
        videoUrl: `https://www.youtube.com/watch?v=${videoId}`,
        tags: snippet?.tags ?? [],
        location,
        recordingDate: formatDate(recordingDetails?.recordingDate),
      } satisfies VideoData;
    })
  );

  return videos;
}

async function extractLocation({
  recordingDetails,
  locationDescription,
}: {
  recordingDetails?: RecordingDetails;
  locationDescription: string | null;
}): Promise<VideoLocation | undefined> {
  const latitude = recordingDetails?.location?.latitude;
  const longitude = recordingDetails?.location?.longitude;

  if (typeof latitude === 'number' && typeof longitude === 'number') {
    const reverseGeocoded = await reverseGeocode(latitude, longitude);
    return {
      latitude,
      longitude,
      city: reverseGeocoded?.city,
      country: reverseGeocoded?.country,
    };
  }

  if (locationDescription) {
    const parsed = parseLocationDescription(locationDescription);
    if (parsed) {
      return parsed;
    }
  }

  return undefined;
}

export async function enhanceLocationData(videos: VideoData[]) {
  let changed = false;

  const nextVideos = await Promise.all(
    videos.map(async (video) => {
      if (
        typeof video.location?.latitude !== 'number' ||
        typeof video.location?.longitude !== 'number' ||
        (video.location.city && video.location.country)
      ) {
        return video;
      }

      const reverseGeocoded = await reverseGeocode(video.location.latitude, video.location.longitude);
      if (!reverseGeocoded) {
        return video;
      }

      changed = true;
      return {
        ...video,
        location: {
          ...video.location,
          city: video.location.city ?? reverseGeocoded.city,
          country: video.location.country ?? reverseGeocoded.country,
        },
      };
    })
  );

  return changed ? nextVideos : videos;
}

function parseLocationDescription(value: string): VideoLocation | undefined {
  const match = value.match(/^\s*([^,]+)\s*,\s*([^,]+)\s*$/);
  if (!match) {
    return undefined;
  }

  return {
    city: match[1].trim(),
    country: match[2].trim(),
  };
}

async function reverseGeocode(latitude: number, longitude: number) {
  reverseGeocodeQueue = reverseGeocodeQueue.then(
    () =>
      new Promise<void>((resolve) => {
        setTimeout(resolve, 1000);
      })
  );

  await reverseGeocodeQueue;

  try {
    const url = new URL('https://nominatim.openstreetmap.org/reverse');
    url.searchParams.set('format', 'jsonv2');
    url.searchParams.set('lat', latitude.toString());
    url.searchParams.set('lon', longitude.toString());

    const response = await fetch(url.toString(), {
      headers: {
        'User-Agent': 'YouTube-Video-App/1.0',
      },
    });

    if (!response.ok) {
      return null;
    }

    const data = (await response.json()) as {
      address?: {
        city?: string;
        town?: string;
        village?: string;
        country?: string;
      };
    };

    return {
      city: data.address?.city ?? data.address?.town ?? data.address?.village,
      country: data.address?.country,
    };
  } catch (error) {
    console.warn('Reverse geocoding failed', error);
    return null;
  }
}

function formatDate(value?: string) {
  if (!value) {
    return undefined;
  }

  return new Date(value).toISOString().split('T')[0];
}
