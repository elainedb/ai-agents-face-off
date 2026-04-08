import { youtubeApiKey } from '@/src/config/api-config';
import { ServerException, ValidationException } from '@/src/core/error/exceptions';
import { VideoModel } from '@/src/features/videos/data/models/video-model';
import { GeocodingService } from '@/src/features/videos/data/services/geocoding-service';

const SEARCH_API = 'https://www.googleapis.com/youtube/v3/search';
const VIDEOS_API = 'https://www.googleapis.com/youtube/v3/videos';

interface SearchItem {
  id?: { videoId?: string };
}

interface VideoDetailsItem {
  id: string;
  snippet?: {
    title?: string;
    channelTitle?: string;
    publishedAt?: string;
    tags?: string[];
    thumbnails?: {
      high?: { url?: string };
      medium?: { url?: string };
      default?: { url?: string };
    };
    description?: string;
  };
  recordingDetails?: {
    location?: {
      latitude?: number;
      longitude?: number;
    };
    recordingDate?: string;
    locationDescription?: string;
  };
}

export class VideosRemoteDataSource {
  constructor(private readonly geocodingService: GeocodingService) {}

  private async fetchJson<T>(url: string): Promise<T> {
    const response = await fetch(url);

    if (!response.ok) {
      throw new ServerException(`YouTube API request failed with status ${response.status}.`);
    }

    return (await response.json()) as T;
  }

  private async fetchVideoIdsForChannel(channelId: string): Promise<string[]> {
    const videoIds: string[] = [];
    let nextPageToken: string | undefined;

    do {
      const params = new URLSearchParams({
        part: 'snippet',
        order: 'date',
        maxResults: '50',
        type: 'video',
        channelId,
        key: youtubeApiKey,
      });

      if (nextPageToken) {
        params.set('pageToken', nextPageToken);
      }

      const response = await this.fetchJson<{ items?: SearchItem[]; nextPageToken?: string }>(
        `${SEARCH_API}?${params.toString()}`
      );

      const ids = (response.items ?? [])
        .map((item) => item.id?.videoId)
        .filter((id): id is string => Boolean(id));

      videoIds.push(...ids);
      nextPageToken = response.nextPageToken;
    } while (nextPageToken);

    return videoIds;
  }

  private async fetchVideoDetails(videoIds: string[]): Promise<VideoDetailsItem[]> {
    const batches: string[][] = [];

    for (let index = 0; index < videoIds.length; index += 50) {
      batches.push(videoIds.slice(index, index + 50));
    }

    const responses = await Promise.all(
      batches.map((batch) => {
        const params = new URLSearchParams({
          part: 'snippet,recordingDetails',
          id: batch.join(','),
          key: youtubeApiKey,
          maxResults: '50',
        });

        return this.fetchJson<{ items?: VideoDetailsItem[] }>(`${VIDEOS_API}?${params.toString()}`);
      })
    );

    return responses.flatMap((response) => response.items ?? []);
  }

  async getVideosFromChannels(channelIds: string[]): Promise<VideoModel[]> {
    if (!youtubeApiKey || youtubeApiKey.startsWith('YOUR_')) {
      throw new ValidationException('A valid YouTube API key is required.');
    }

    const channelResults = await Promise.all(
      channelIds.map((channelId) => this.fetchVideoIdsForChannel(channelId))
    );

    const allVideoIds = [...new Set(channelResults.flat())];
    if (allVideoIds.length === 0) {
      return [];
    }

    const detailItems = await this.fetchVideoDetails(allVideoIds);
    const videos: VideoModel[] = [];

    for (const item of detailItems) {
      const latitude = item.recordingDetails?.location?.latitude ?? null;
      const longitude = item.recordingDetails?.location?.longitude ?? null;

      const geocoded =
        latitude !== null && longitude !== null
          ? await this.geocodingService.reverseGeocode(
              latitude,
              longitude,
              item.recordingDetails?.locationDescription ?? item.snippet?.description ?? null
            )
          : { city: null, country: null };

      videos.push(
        VideoModel.fromJson({
          id: item.id,
          title: item.snippet?.title ?? 'Untitled Video',
          channelName: item.snippet?.channelTitle ?? 'Unknown Channel',
          thumbnailUrl:
            item.snippet?.thumbnails?.high?.url ??
            item.snippet?.thumbnails?.medium?.url ??
            item.snippet?.thumbnails?.default?.url ??
            'https://i.ytimg.com/vi/default/hqdefault.jpg',
          publishedAt: item.snippet?.publishedAt ?? new Date(0).toISOString(),
          tags: item.snippet?.tags ?? [],
          city: geocoded.city,
          country: geocoded.country,
          latitude,
          longitude,
          recordingDate: item.recordingDetails?.recordingDate ?? null,
        })
      );
    }

    return videos.sort(
      (left, right) => new Date(right.publishedAt).getTime() - new Date(left.publishedAt).getTime()
    );
  }
}
