import { youtubeApiKey } from '@/src/config/api-config';
import { ServerException, ValidationException } from '@/src/core/error/exceptions';
import { VideoModel } from '@/src/features/videos/data/models/video-model';
import { GeocodingService } from '@/src/features/videos/data/services/geocoding-service';

type SearchResponse = {
  items?: {
    id?: { videoId?: string };
  }[];
  nextPageToken?: string;
};

type VideoDetailsResponse = {
  items?: {
    id?: string;
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
    };
    recordingDetails?: {
      recordingDate?: string;
      locationDescription?: string;
      location?: {
        latitude?: number;
        longitude?: number;
      };
    };
  }[];
};

export class VideosRemoteDataSource {
  constructor(private readonly geocodingService: GeocodingService) {}

  async getVideosFromChannels(channelIds: string[]): Promise<VideoModel[]> {
    const allVideoIds = await Promise.all(
      channelIds.map(async (channelId) => this.fetchAllVideoIdsForChannel(channelId)),
    );

    const uniqueIds = [...new Set(allVideoIds.flat())];
    const detailBatches = this.chunk(uniqueIds, 50);
    const details = await Promise.all(detailBatches.map(async (ids) => this.fetchVideoDetails(ids)));

    const videos: VideoModel[] = [];

    for (const item of details.flat()) {
      const latitude = item.recordingDetails?.location?.latitude ?? null;
      const longitude = item.recordingDetails?.location?.longitude ?? null;
      const location =
        latitude != null && longitude != null
          ? await this.geocodingService.reverseGeocode(
              latitude,
              longitude,
              item.recordingDetails?.locationDescription,
            )
          : { city: null, country: null };

      videos.push(
        VideoModel.fromJson({
          id: item.id ?? '',
          title: item.snippet?.title ?? '',
          channelName: item.snippet?.channelTitle ?? '',
          thumbnailUrl:
            item.snippet?.thumbnails?.high?.url ??
            item.snippet?.thumbnails?.medium?.url ??
            item.snippet?.thumbnails?.default?.url ??
            'https://i.ytimg.com/vi/invalid/hqdefault.jpg',
          publishedAt: item.snippet?.publishedAt ?? '',
          tags: item.snippet?.tags ?? [],
          city: location.city,
          country: location.country,
          latitude,
          longitude,
          recordingDate: item.recordingDetails?.recordingDate ?? null,
        }),
      );
    }

    return videos.sort(
      (left, right) =>
        new Date(right.publishedAt).getTime() - new Date(left.publishedAt).getTime(),
    );
  }

  private async fetchAllVideoIdsForChannel(channelId: string): Promise<string[]> {
    const videoIds: string[] = [];
    let nextPageToken: string | undefined;

    do {
      const params = new URLSearchParams({
        key: youtubeApiKey,
        part: 'snippet',
        order: 'date',
        maxResults: '50',
        type: 'video',
        channelId,
      });

      if (nextPageToken) {
        params.set('pageToken', nextPageToken);
      }

      const response = await fetch(
        `https://www.googleapis.com/youtube/v3/search?${params.toString()}`,
      );

      if (!response.ok) {
        throw new ServerException(`YouTube search failed with ${response.status}.`);
      }

      const payload = (await response.json()) as SearchResponse;
      videoIds.push(
        ...(payload.items ?? [])
          .map((item) => item.id?.videoId)
          .filter((value): value is string => typeof value === 'string' && value.length > 0),
      );
      nextPageToken = payload.nextPageToken;
    } while (nextPageToken);

    return videoIds;
  }

  private async fetchVideoDetails(ids: string[]): Promise<NonNullable<VideoDetailsResponse['items']>> {
    if (ids.length === 0) {
      return [];
    }

    const params = new URLSearchParams({
      key: youtubeApiKey,
      part: 'snippet,recordingDetails',
      id: ids.join(','),
      maxResults: '50',
    });

    const response = await fetch(`https://www.googleapis.com/youtube/v3/videos?${params.toString()}`);

    if (!response.ok) {
      throw new ServerException(`YouTube details failed with ${response.status}.`);
    }

    const payload = (await response.json()) as VideoDetailsResponse;

    if (!Array.isArray(payload.items)) {
      throw new ValidationException('YouTube returned an invalid videos payload.');
    }

    return payload.items;
  }

  private chunk<T>(items: T[], size: number): T[][] {
    const chunks: T[][] = [];

    for (let index = 0; index < items.length; index += size) {
      chunks.push(items.slice(index, index + size));
    }

    return chunks;
  }
}
