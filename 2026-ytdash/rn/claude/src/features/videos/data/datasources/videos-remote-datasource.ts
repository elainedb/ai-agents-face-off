import { youtubeApiKey } from '../../../../config/api-config';
import { ServerException } from '../../../../core/error/exceptions';
import { VideoModel } from '../models/video-model';
import { reverseGeocode } from '../services/geocoding-service';

const BASE_URL = 'https://www.googleapis.com/youtube/v3';

interface SearchItem {
  id?: { videoId?: string };
}

interface SearchResponse {
  items?: SearchItem[];
  nextPageToken?: string;
}

interface VideoSnippet {
  title?: string;
  channelTitle?: string;
  thumbnails?: { high?: { url?: string }; medium?: { url?: string }; default?: { url?: string } };
  publishedAt?: string;
  tags?: string[];
}

interface RecordingDetails {
  location?: { latitude?: number; longitude?: number };
  locationDescription?: string;
  recordingDate?: string;
}

interface VideoItem {
  id?: string;
  snippet?: VideoSnippet;
  recordingDetails?: RecordingDetails;
}

interface VideosResponse {
  items?: VideoItem[];
}

export interface VideosRemoteDataSource {
  getVideosFromChannels(channelIds: string[]): Promise<VideoModel[]>;
}

export class VideosRemoteDataSourceImpl implements VideosRemoteDataSource {
  async getVideosFromChannels(channelIds: string[]): Promise<VideoModel[]> {
    try {
      const allVideoIds = await Promise.all(
        channelIds.map((channelId) => this.fetchAllVideoIds(channelId)),
      );
      const flatIds = allVideoIds.flat();

      if (flatIds.length === 0) return [];

      const batches: string[][] = [];
      for (let i = 0; i < flatIds.length; i += 50) {
        batches.push(flatIds.slice(i, i + 50));
      }

      const detailedResults = await Promise.all(
        batches.map((batch) => this.fetchVideoDetails(batch)),
      );
      const allVideos = detailedResults.flat();

      // Reverse geocode videos with coordinates (sequential due to rate limit)
      for (const video of allVideos) {
        if (video.latitude != null && video.longitude != null) {
          const geo = await reverseGeocode(video.latitude, video.longitude);
          video.city = geo.city;
          video.country = geo.country;
        }
      }

      allVideos.sort(
        (a, b) => new Date(b.publishedAt).getTime() - new Date(a.publishedAt).getTime(),
      );

      return allVideos;
    } catch (error: unknown) {
      throw new ServerException(
        `Failed to fetch videos: ${error instanceof Error ? error.message : String(error)}`,
      );
    }
  }

  private async fetchAllVideoIds(channelId: string): Promise<string[]> {
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
      const items = data.items ?? [];
      for (const item of items) {
        if (item.id?.videoId) ids.push(item.id.videoId);
      }
      pageToken = data.nextPageToken;
    } while (pageToken);

    return ids;
  }

  private async fetchVideoDetails(videoIds: string[]): Promise<VideoModel[]> {
    const params = new URLSearchParams({
      part: 'snippet,recordingDetails',
      id: videoIds.join(','),
      key: youtubeApiKey,
    });

    const response = await fetch(`${BASE_URL}/videos?${params}`);
    if (!response.ok) {
      throw new ServerException(`YouTube videos API error: ${response.status}`);
    }
    const data: VideosResponse = await response.json();
    const items = data.items ?? [];

    return items.map((item) => {
      const snippet = item.snippet ?? {};
      const recording = item.recordingDetails;
      const thumbnails = snippet.thumbnails ?? {};
      const thumbnailUrl =
        thumbnails.high?.url ?? thumbnails.medium?.url ?? thumbnails.default?.url ?? '';

      return new VideoModel(
        item.id ?? '',
        snippet.title ?? '',
        snippet.channelTitle ?? '',
        thumbnailUrl,
        snippet.publishedAt ?? new Date().toISOString(),
        snippet.tags ?? [],
        null,
        null,
        recording?.location?.latitude ?? null,
        recording?.location?.longitude ?? null,
        recording?.recordingDate ?? null,
      );
    });
  }
}
