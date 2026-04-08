import { youtubeApiKey } from '@/src/config/api-config';
import { ServerException } from '@/src/core/error/exceptions';
import { VideoModel, videoModelSchema } from '../models/video-model';
import { reverseGeocode } from '../services/geocoding-service';

const BASE_URL = 'https://www.googleapis.com/youtube/v3';

interface SearchItem {
  id: { videoId: string };
}

interface SearchResponse {
  items: SearchItem[];
  nextPageToken?: string;
}

interface VideoDetailSnippet {
  title: string;
  channelTitle: string;
  publishedAt: string;
  tags?: string[];
  thumbnails: { high?: { url: string }; medium?: { url: string }; default?: { url: string } };
}

interface VideoDetailRecording {
  location?: { latitude: number; longitude: number };
  locationDescription?: string;
  recordingDate?: string;
}

interface VideoDetailItem {
  id: string;
  snippet: VideoDetailSnippet;
  recordingDetails?: VideoDetailRecording;
}

interface VideosResponse {
  items: VideoDetailItem[];
}

async function fetchAllVideoIdsForChannel(channelId: string): Promise<string[]> {
  const ids: string[] = [];
  let pageToken: string | undefined;

  do {
    const params = new URLSearchParams({
      part: 'snippet',
      channelId,
      type: 'video',
      order: 'date',
      maxResults: '50',
      key: youtubeApiKey,
    });
    if (pageToken) params.set('pageToken', pageToken);

    const response = await fetch(`${BASE_URL}/search?${params}`);
    if (!response.ok) {
      throw new ServerException(`YouTube search API error: ${response.status}`);
    }

    const data: SearchResponse = await response.json();
    for (const item of data.items) {
      if (item.id?.videoId) {
        ids.push(item.id.videoId);
      }
    }
    pageToken = data.nextPageToken;
  } while (pageToken);

  return ids;
}

async function fetchVideoDetails(videoIds: string[]): Promise<VideoDetailItem[]> {
  const allDetails: VideoDetailItem[] = [];

  for (let i = 0; i < videoIds.length; i += 50) {
    const batch = videoIds.slice(i, i + 50);
    const params = new URLSearchParams({
      part: 'snippet,recordingDetails',
      id: batch.join(','),
      key: youtubeApiKey,
    });

    const response = await fetch(`${BASE_URL}/videos?${params}`);
    if (!response.ok) {
      throw new ServerException(`YouTube videos API error: ${response.status}`);
    }

    const data: VideosResponse = await response.json();
    allDetails.push(...data.items);
  }

  return allDetails;
}

export class VideosRemoteDataSource {
  async getVideosFromChannels(channelIds: string[]): Promise<VideoModel[]> {
    try {
      const channelResults = await Promise.all(
        channelIds.map((id) => fetchAllVideoIdsForChannel(id)),
      );
      const allVideoIds = channelResults.flat();

      if (allVideoIds.length === 0) return [];

      const details = await fetchVideoDetails(allVideoIds);

      const models: VideoModel[] = [];
      for (const item of details) {
        const thumbnails = item.snippet.thumbnails;
        const thumbnailUrl =
          thumbnails.high?.url || thumbnails.medium?.url || thumbnails.default?.url || '';

        let city: string | null = null;
        let country: string | null = null;
        const lat = item.recordingDetails?.location?.latitude ?? null;
        const lng = item.recordingDetails?.location?.longitude ?? null;

        if (lat != null && lng != null) {
          const geo = await reverseGeocode(
            lat,
            lng,
            item.recordingDetails?.locationDescription,
          );
          city = geo.city;
          country = geo.country;
        }

        const raw = {
          id: item.id,
          title: item.snippet.title,
          channelName: item.snippet.channelTitle,
          thumbnailUrl,
          publishedAt: item.snippet.publishedAt,
          tags: item.snippet.tags ?? [],
          city,
          country,
          latitude: lat,
          longitude: lng,
          recordingDate: item.recordingDetails?.recordingDate ?? null,
        };

        const parsed = videoModelSchema.safeParse(raw);
        if (parsed.success) {
          models.push(
            new VideoModel(
              parsed.data.id,
              parsed.data.title,
              parsed.data.channelName,
              parsed.data.thumbnailUrl,
              parsed.data.publishedAt,
              parsed.data.tags,
              parsed.data.city,
              parsed.data.country,
              parsed.data.latitude,
              parsed.data.longitude,
              parsed.data.recordingDate,
            ),
          );
        }
      }

      models.sort((a, b) => new Date(b.publishedAt).getTime() - new Date(a.publishedAt).getTime());
      return models;
    } catch (error) {
      if (error instanceof ServerException) throw error;
      const message = error instanceof Error ? error.message : 'Unknown error fetching videos';
      throw new ServerException(message);
    }
  }
}
