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

async function rateLimitedNominatim(lat: number, lon: number): Promise<{ city?: string; country?: string }> {
  const now = Date.now();
  const elapsed = now - lastNominatimCall;
  if (elapsed < 1000) {
    await new Promise((resolve) => setTimeout(resolve, 1000 - elapsed));
  }
  lastNominatimCall = Date.now();

  try {
    const response = await fetch(
      `https://nominatim.openstreetmap.org/reverse?format=json&lat=${lat}&lon=${lon}`,
      {
        headers: {
          'User-Agent': 'YouTube-Video-App/1.0',
        },
      }
    );
    const data = await response.json();
    return {
      city: data.address?.city || data.address?.town || data.address?.village,
      country: data.address?.country,
    };
  } catch {
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
    const searchUrl = `${API_BASE}/search?part=snippet&channelId=${channelId}&order=date&maxResults=50&type=video&key=${youtubeApiKey}`;
    const searchResponse = await fetch(searchUrl);
    const searchData = await searchResponse.json();

    if (!searchData.items || searchData.items.length === 0) {
      return [];
    }

    const videoIds = searchData.items.map((item: any) => item.id.videoId).join(',');

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
      const videoId = searchItem.id.videoId;
      const detail = detailsMap.get(videoId);
      const snippet = detail?.snippet || searchItem.snippet;

      const thumbnailUrl =
        snippet.thumbnails?.medium?.url ||
        snippet.thumbnails?.default?.url ||
        '';

      let location: VideoData['location'] | undefined;
      const recordingDetails = detail?.recordingDetails;

      if (recordingDetails?.location) {
        const lat = recordingDetails.location.latitude;
        const lon = recordingDetails.location.longitude;
        location = { latitude: lat, longitude: lon };

        const locationDesc = parseLocationDescription(snippet.locationDescription);
        if (locationDesc.city) {
          location.city = locationDesc.city;
          location.country = locationDesc.country;
        }
      }

      let recordingDate: string | undefined;
      if (recordingDetails?.recordingDate) {
        recordingDate = new Date(recordingDetails.recordingDate)
          .toISOString()
          .split('T')[0];
      }

      videos.push({
        id: videoId,
        title: snippet.title,
        channelName: snippet.channelTitle,
        publishedAt: snippet.publishedAt,
        thumbnailUrl,
        videoUrl: `https://www.youtube.com/watch?v=${videoId}`,
        tags: snippet.tags || [],
        location,
        recordingDate,
      });
    }

    return videos;
  } catch (err) {
    console.error(`Error fetching channel ${channelId}:`, err);
    return [];
  }
}

export async function enhanceLocationData(videos: VideoData[]): Promise<VideoData[]> {
  const enhanced = [...videos];
  for (const video of enhanced) {
    if (
      video.location?.latitude != null &&
      video.location?.longitude != null &&
      (!video.location.city || !video.location.country)
    ) {
      const geocoded = await rateLimitedNominatim(
        video.location.latitude,
        video.location.longitude
      );
      if (geocoded.city) video.location!.city = geocoded.city;
      if (geocoded.country) video.location!.country = geocoded.country;
    }
  }
  return enhanced;
}

export async function fetchAllVideos(forceRefresh = false): Promise<VideoData[]> {
  // Cache integration is handled in cacheService.ts
  // This function always fetches fresh data from the API
  const channelPromises = CHANNEL_IDS.map((id) => fetchChannelVideos(id));
  const results = await Promise.all(channelPromises);
  const allVideos = results.flat();

  allVideos.sort(
    (a, b) => new Date(b.publishedAt).getTime() - new Date(a.publishedAt).getTime()
  );

  return allVideos;
}
