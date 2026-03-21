import { youtubeApiKey } from '../config.js';

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

const API_BASE = 'https://www.googleapis.com/youtube/v3';

let lastNominatimCall = 0;

async function reverseGeocode(
  lat: number,
  lon: number
): Promise<{ city?: string; country?: string }> {
  const now = Date.now();
  const timeSinceLastCall = now - lastNominatimCall;
  if (timeSinceLastCall < 1000) {
    await new Promise((resolve) => setTimeout(resolve, 1000 - timeSinceLastCall));
  }
  lastNominatimCall = Date.now();

  try {
    const response = await fetch(
      `https://nominatim.openstreetmap.org/reverse?lat=${lat}&lon=${lon}&format=json`,
      {
        headers: {
          'User-Agent': 'YouTube-Video-App/1.0',
        },
      }
    );
    const data = await response.json();
    return {
      city:
        data.address?.city ||
        data.address?.town ||
        data.address?.village ||
        data.address?.municipality,
      country: data.address?.country,
    };
  } catch (e) {
    console.log('Reverse geocoding failed:', e);
    return {};
  }
}

function parseLocationDescription(
  description?: string
): { city?: string; country?: string } {
  if (!description) return {};
  const match = description.match(/^([^,]+),\s*(.+)$/);
  if (match) {
    return { city: match[1].trim(), country: match[2].trim() };
  }
  return {};
}

async function fetchChannelVideos(channelId: string): Promise<VideoData[]> {
  try {
    const searchUrl = `${API_BASE}/search?part=snippet&channelId=${channelId}&order=date&maxResults=50&type=video&key=${youtubeApiKey}`;
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

    const detailsUrl = `${API_BASE}/videos?part=snippet,recordingDetails,localizations&id=${videoIds}&key=${youtubeApiKey}`;
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

      const details = detailsMap.get(videoId);
      const snippet = details?.snippet || searchItem.snippet;
      const recordingDetails = details?.recordingDetails;

      let location: VideoData['location'] | undefined;
      const lat = recordingDetails?.location?.latitude;
      const lon = recordingDetails?.location?.longitude;

      if (lat !== undefined && lon !== undefined) {
        let city: string | undefined;
        let country: string | undefined;

        const locationDesc = snippet?.locationDescription;
        if (locationDesc) {
          const parsed = parseLocationDescription(locationDesc);
          city = parsed.city;
          country = parsed.country;
        }

        if (!city || !country) {
          const geocoded = await reverseGeocode(lat, lon);
          city = city || geocoded.city;
          country = country || geocoded.country;
        }

        location = { city, country, latitude: lat, longitude: lon };
      } else if (snippet?.locationDescription) {
        const parsed = parseLocationDescription(snippet.locationDescription);
        if (parsed.city || parsed.country) {
          location = { city: parsed.city, country: parsed.country };
        }
      }

      let recordingDate: string | undefined;
      if (recordingDetails?.recordingDate) {
        try {
          recordingDate = new Date(recordingDetails.recordingDate)
            .toISOString()
            .split('T')[0];
        } catch {
          // ignore invalid dates
        }
      }

      const thumbnail =
        snippet?.thumbnails?.medium?.url ||
        snippet?.thumbnails?.default?.url ||
        '';

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
  } catch (e) {
    console.error(`Error fetching channel ${channelId}:`, e);
    return [];
  }
}

export async function enhanceLocationData(
  videos: VideoData[]
): Promise<VideoData[]> {
  const enhanced = [...videos];
  for (const video of enhanced) {
    if (
      video.location?.latitude !== undefined &&
      video.location?.longitude !== undefined &&
      (!video.location.city || !video.location.country)
    ) {
      const geocoded = await reverseGeocode(
        video.location.latitude,
        video.location.longitude
      );
      video.location.city = video.location.city || geocoded.city;
      video.location.country = video.location.country || geocoded.country;
    }
  }
  return enhanced;
}

export async function fetchAllVideos(
  forceRefresh = false
): Promise<VideoData[]> {
  // Import cache service dynamically to avoid circular deps
  const { getFromCache, saveToCache } = await import('./cacheService');

  if (!forceRefresh) {
    const cached = await getFromCache();
    if (cached) {
      // Enhance location data in background
      enhanceLocationData(cached).then((enhanced) => {
        saveToCache(enhanced);
      });
      return cached;
    }
  }

  const results = await Promise.all(
    CHANNEL_IDS.map((id) => fetchChannelVideos(id))
  );

  const allVideos = results
    .flat()
    .sort(
      (a, b) =>
        new Date(b.publishedAt).getTime() - new Date(a.publishedAt).getTime()
    );

  await saveToCache(allVideos);
  return allVideos;
}
