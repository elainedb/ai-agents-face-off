import { youtubeApiKey } from '@/config.js';

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

const YOUTUBE_API_BASE = 'https://www.googleapis.com/youtube/v3';

let lastNominatimRequest = 0;

async function rateLimitedNominatim(lat: number, lon: number): Promise<{ city?: string; country?: string }> {
  const now = Date.now();
  const timeSinceLastRequest = now - lastNominatimRequest;
  if (timeSinceLastRequest < 1500) {
    await new Promise(resolve => setTimeout(resolve, 1500 - timeSinceLastRequest));
  }
  lastNominatimRequest = Date.now();

  try {
    const response = await fetch(
      `https://nominatim.openstreetmap.org/reverse?format=json&lat=${lat}&lon=${lon}`,
      {
        headers: {
          'User-Agent': 'YouTube-Video-App/1.0',
          'Accept': 'application/json',
        },
      }
    );

    if (!response.ok) {
      console.warn(`Nominatim returned status ${response.status} for ${lat},${lon}`);
      return {};
    }

    const contentType = response.headers.get('content-type') || '';
    if (!contentType.includes('json')) {
      console.warn(`Nominatim returned non-JSON content-type: ${contentType}`);
      return {};
    }

    const data = await response.json();
    return {
      city: data.address?.city || data.address?.town || data.address?.village,
      country: data.address?.country,
    };
  } catch (error) {
    console.warn('Reverse geocoding failed:', error);
    return {};
  }
}

function parseLocationDescription(description?: string): { city?: string; country?: string } {
  if (!description) return {};
  const match = description.match(/^([^,]+),\s*(.+)$/);
  if (match) {
    return { city: match[1].trim(), country: match[2].trim() };
  }
  return {};
}

async function fetchChannelVideos(channelId: string): Promise<VideoData[]> {
  try {
    const searchUrl = `${YOUTUBE_API_BASE}/search?part=snippet&channelId=${channelId}&order=date&maxResults=50&type=video&key=${youtubeApiKey}`;
    const searchResponse = await fetch(searchUrl);
    const searchData = await searchResponse.json();

    if (!searchData.items || searchData.items.length === 0) {
      return [];
    }

    const videoIds = searchData.items
      .map((item: any) => item.id?.videoId)
      .filter(Boolean)
      .join(',');

    if (!videoIds) return [];

    const detailsUrl = `${YOUTUBE_API_BASE}/videos?part=snippet,recordingDetails,localizations&id=${videoIds}&key=${youtubeApiKey}`;
    const detailsResponse = await fetch(detailsUrl);
    const detailsData = await detailsResponse.json();

    const detailsMap = new Map<string, any>();
    if (detailsData.items) {
      for (const item of detailsData.items) {
        detailsMap.set(item.id, item);
      }
    }

    const videos: VideoData[] = [];

    for (const searchItem of searchData.items) {
      const videoId = searchItem.id?.videoId;
      if (!videoId) continue;

      const detail = detailsMap.get(videoId);
      const snippet = detail?.snippet || searchItem.snippet;
      const recordingDetails = detail?.recordingDetails;

      let location: VideoData['location'] | undefined;

      if (recordingDetails?.location) {
        const lat = recordingDetails.location.latitude;
        const lon = recordingDetails.location.longitude;
        if (lat !== undefined && lon !== undefined) {
          location = {
            latitude: lat,
            longitude: lon,
          };
          // city/country will be filled in by enhanceLocationData
        }
      }

      if (!location) {
        const parsed = parseLocationDescription(snippet?.locationDescription);
        if (parsed.city || parsed.country) {
          location = parsed;
        }
      }

      let recordingDate: string | undefined;
      if (recordingDetails?.recordingDate) {
        try {
          recordingDate = new Date(recordingDetails.recordingDate).toISOString().split('T')[0];
        } catch {
          // ignore invalid date
        }
      }

      const thumbnail = snippet?.thumbnails?.medium?.url || snippet?.thumbnails?.default?.url || '';

      videos.push({
        id: videoId,
        title: snippet?.title || '',
        channelName: snippet?.channelTitle || '',
        publishedAt: snippet?.publishedAt || '',
        thumbnailUrl: thumbnail,
        videoUrl: `https://www.youtube.com/watch?v=${videoId}`,
        tags: snippet?.tags || [],
        location,
        recordingDate,
      });
    }

    return videos;
  } catch (error) {
    console.error(`Error fetching channel ${channelId}:`, error);
    return [];
  }
}

export async function enhanceLocationData(videos: VideoData[]): Promise<VideoData[]> {
  const enhanced = [...videos];
  for (const video of enhanced) {
    if (
      video.location?.latitude !== undefined &&
      video.location?.longitude !== undefined &&
      (!video.location.city || !video.location.country)
    ) {
      const geocoded = await rateLimitedNominatim(
        video.location.latitude,
        video.location.longitude
      );
      if (geocoded.city) video.location.city = geocoded.city;
      if (geocoded.country) video.location.country = geocoded.country;
    }
  }
  return enhanced;
}

// Import cache service lazily to avoid circular dependency
let cacheModule: typeof import('./cacheService') | null = null;

async function getCacheModule() {
  if (!cacheModule) {
    cacheModule = await import('./cacheService');
  }
  return cacheModule;
}

export async function fetchAllVideos(forceRefresh = false): Promise<VideoData[]> {
  const cache = await getCacheModule();

  if (!forceRefresh) {
    const cached = await cache.getFromCache();
    if (cached) {
      // Enhance location data in background and update cache
      enhanceLocationData(cached).then(enhanced => {
        cache.saveToCache(enhanced);
      });
      return cached;
    }
  }

  const results = await Promise.all(
    CHANNEL_IDS.map(channelId => fetchChannelVideos(channelId))
  );

  const allVideos = results.flat().sort(
    (a, b) => new Date(b.publishedAt).getTime() - new Date(a.publishedAt).getTime()
  );

  // Reverse geocode locations sequentially, then cache
  const enhanced = await enhanceLocationData(allVideos);
  await cache.saveToCache(enhanced);

  return enhanced;
}
