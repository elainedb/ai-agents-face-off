import { youtubeApiKey } from '../config';

import { getFromCache, saveToCache } from '@/services/cacheService';

const CHANNEL_IDS = [
  'UCynoa1DjwnvHAowA_jiMEAQ',
  'UCK0KOjX3beyB9nzonls0cuw',
  'UCACkIrvrGAQ7kuc0hMVwvmA',
  'UCtWRAKKvOEA0CXOue9BG8ZA',
] as const;

type SearchResponse = {
  items?: Array<{
    id?: {
      videoId?: string;
    };
  }>;
};

type VideosResponse = {
  items?: Array<{
    id: string;
    snippet?: {
      title?: string;
      channelTitle?: string;
      publishedAt?: string;
      tags?: string[];
      thumbnails?: {
        medium?: { url?: string };
        default?: { url?: string };
      };
      localized?: {
        title?: string;
      };
      description?: string;
      locationDescription?: string;
    };
    recordingDetails?: {
      recordingDate?: string;
      location?: {
        latitude?: number;
        longitude?: number;
      };
    };
  }>;
};

export type VideoData = {
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
};

let reverseGeocodeChain = Promise.resolve();
let lastReverseGeocodeAt = 0;

function formatDate(value?: string) {
  if (!value) {
    return undefined;
  }

  return new Date(value).toISOString().split('T')[0];
}

function parseLocationDescription(locationDescription?: string) {
  if (!locationDescription) {
    return {};
  }

  const cityCountryMatch = locationDescription.match(/^\s*([^,]+),\s*([^,]+)\s*$/);
  if (!cityCountryMatch) {
    return {
      country: locationDescription.trim(),
    };
  }

  return {
    city: cityCountryMatch[1].trim(),
    country: cityCountryMatch[2].trim(),
  };
}

async function reverseGeocode(latitude: number, longitude: number) {
  reverseGeocodeChain = reverseGeocodeChain.then(async () => {
    const now = Date.now();
    const waitMs = Math.max(0, 1000 - (now - lastReverseGeocodeAt));
    if (waitMs > 0) {
      await new Promise((resolve) => setTimeout(resolve, waitMs));
    }

    lastReverseGeocodeAt = Date.now();
  });

  await reverseGeocodeChain;

  const response = await fetch(
    `https://nominatim.openstreetmap.org/reverse?format=jsonv2&lat=${latitude}&lon=${longitude}`,
    {
      headers: {
        Accept: 'application/json',
        'User-Agent': 'YouTube-Video-App/1.0',
      },
    }
  );

  if (!response.ok) {
    throw new Error(`Reverse geocoding failed with status ${response.status}`);
  }

  const payload = (await response.json()) as {
    address?: {
      city?: string;
      town?: string;
      village?: string;
      state?: string;
      country?: string;
    };
  };

  return {
    city: payload.address?.city ?? payload.address?.town ?? payload.address?.village ?? payload.address?.state,
    country: payload.address?.country,
  };
}

async function enhanceLocationData(videos: VideoData[]) {
  const enhancedVideos = [...videos];

  for (let index = 0; index < enhancedVideos.length; index += 1) {
    const video = enhancedVideos[index];
    if (
      video.location?.latitude == null ||
      video.location?.longitude == null ||
      (video.location.city && video.location.country)
    ) {
      continue;
    }

    try {
      const location = await reverseGeocode(video.location.latitude, video.location.longitude);
      enhancedVideos[index] = {
        ...video,
        location: {
          ...video.location,
          ...location,
        },
      };
    } catch (error) {
      console.log('Failed to reverse geocode location', error);
    }
  }

  return enhancedVideos;
}

async function fetchChannelVideoIds(channelId: string) {
  const url =
    `https://www.googleapis.com/youtube/v3/search?part=snippet&order=date&type=video&maxResults=50&channelId=${channelId}&key=${youtubeApiKey}`;
  const response = await fetch(url);
  if (!response.ok) {
    throw new Error(`YouTube search request failed with status ${response.status}`);
  }

  const payload = (await response.json()) as SearchResponse;
  return payload.items?.map((item) => item.id?.videoId).filter((videoId): videoId is string => Boolean(videoId)) ?? [];
}

async function fetchChannelVideos(channelId: string) {
  const videoIds = await fetchChannelVideoIds(channelId);
  if (videoIds.length === 0) {
    return [];
  }

  const detailsUrl =
    `https://www.googleapis.com/youtube/v3/videos?part=snippet,recordingDetails,localizations&id=${videoIds.join(',')}&key=${youtubeApiKey}`;
  const detailsResponse = await fetch(detailsUrl);
  if (!detailsResponse.ok) {
    throw new Error(`YouTube videos request failed with status ${detailsResponse.status}`);
  }

  const detailsPayload = (await detailsResponse.json()) as VideosResponse;

  return (
    detailsPayload.items?.map((item) => {
      const fallbackLocation = parseLocationDescription(item.snippet?.locationDescription);
      const latitude = item.recordingDetails?.location?.latitude;
      const longitude = item.recordingDetails?.location?.longitude;

      return {
        channelName: item.snippet?.channelTitle ?? 'Unknown Channel',
        id: item.id,
        location:
          latitude != null && longitude != null
            ? {
                ...fallbackLocation,
                latitude,
                longitude,
              }
            : Object.keys(fallbackLocation).length > 0
              ? fallbackLocation
              : undefined,
        publishedAt: item.snippet?.publishedAt ?? new Date().toISOString(),
        recordingDate: formatDate(item.recordingDetails?.recordingDate),
        tags: item.snippet?.tags ?? [],
        thumbnailUrl:
          item.snippet?.thumbnails?.medium?.url ??
          item.snippet?.thumbnails?.default?.url ??
          'https://placehold.co/120x90?text=Video',
        title: item.snippet?.localized?.title ?? item.snippet?.title ?? 'Untitled Video',
        videoUrl: `https://www.youtube.com/watch?v=${item.id}`,
      } satisfies VideoData;
    }) ?? []
  );
}

export async function fetchAllVideos(forceRefresh = false) {
  if (!forceRefresh) {
    const cachedVideos = await getFromCache();
    if (cachedVideos) {
      const enhancedCachedVideos = await enhanceLocationData(cachedVideos);
      if (JSON.stringify(enhancedCachedVideos) !== JSON.stringify(cachedVideos)) {
        await saveToCache(enhancedCachedVideos);
      }

      return enhancedCachedVideos.sort(
        (left, right) => new Date(right.publishedAt).getTime() - new Date(left.publishedAt).getTime()
      );
    }
  }

  const videosByChannel = await Promise.all(CHANNEL_IDS.map((channelId) => fetchChannelVideos(channelId)));
  const mergedVideos = videosByChannel
    .flat()
    .sort((left, right) => new Date(right.publishedAt).getTime() - new Date(left.publishedAt).getTime());

  const enhancedVideos = await enhanceLocationData(mergedVideos);
  await saveToCache(enhancedVideos);
  return enhancedVideos;
}
