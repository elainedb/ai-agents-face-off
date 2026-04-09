import { youtubeApiKey } from '@/src/config/api-config';
import { ServerException } from '@/src/core/error/exceptions';
import { VideoModel } from '../models/video-model';
import { GeocodingService } from '../services/geocoding-service';

export interface VideosRemoteDataSource {
  getVideosFromChannels(channelIds: string[]): Promise<VideoModel[]>;
}

interface SearchItem {
  id: { videoId: string };
  snippet: { channelTitle: string };
}

interface SearchResponse {
  items?: SearchItem[];
  nextPageToken?: string;
}

interface VideoDetailItem {
  id: string;
  snippet: {
    title: string;
    channelTitle: string;
    publishedAt: string;
    thumbnails: { high?: { url: string }; medium?: { url: string }; default?: { url: string } };
    tags?: string[];
  };
  recordingDetails?: {
    location?: { latitude: number; longitude: number };
    locationDescription?: string;
    recordingDate?: string;
  };
}

interface VideoDetailResponse {
  items?: VideoDetailItem[];
}

export class VideosRemoteDataSourceImpl implements VideosRemoteDataSource {
  private geocodingService = new GeocodingService();

  async getVideosFromChannels(channelIds: string[]): Promise<VideoModel[]> {
    try {
      const allSearchResults = await Promise.all(
        channelIds.map((id) => this.searchChannel(id)),
      );
      const searchItems = allSearchResults.flat();

      if (searchItems.length === 0) return [];

      const videoIds = searchItems.map((item) => item.id.videoId);
      const detailedVideos = await this.getVideoDetails(videoIds);

      // Geocode videos with coordinates sequentially
      for (const video of detailedVideos) {
        if (video.latitude != null && video.longitude != null && !video.city && !video.country) {
          const geo = await this.geocodingService.reverseGeocode(
            video.latitude,
            video.longitude,
          );
          video.city = geo.city;
          video.country = geo.country;
        }
      }

      detailedVideos.sort(
        (a, b) => new Date(b.publishedAt).getTime() - new Date(a.publishedAt).getTime(),
      );

      return detailedVideos;
    } catch (error) {
      throw new ServerException(
        error instanceof Error ? error.message : 'Failed to fetch videos',
      );
    }
  }

  private async searchChannel(channelId: string): Promise<SearchItem[]> {
    const items: SearchItem[] = [];
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

      const response = await fetch(
        `https://www.googleapis.com/youtube/v3/search?${params}`,
      );
      if (!response.ok) {
        throw new ServerException(`YouTube search API error: ${response.status}`);
      }
      const data: SearchResponse = await response.json();
      if (data.items) items.push(...data.items);
      pageToken = data.nextPageToken;
    } while (pageToken);

    return items;
  }

  private async getVideoDetails(videoIds: string[]): Promise<VideoModel[]> {
    const videos: VideoModel[] = [];
    const batchSize = 50;

    for (let i = 0; i < videoIds.length; i += batchSize) {
      const batch = videoIds.slice(i, i + batchSize);
      const params = new URLSearchParams({
        part: 'snippet,recordingDetails',
        id: batch.join(','),
        key: youtubeApiKey,
      });

      const response = await fetch(
        `https://www.googleapis.com/youtube/v3/videos?${params}`,
      );
      if (!response.ok) {
        throw new ServerException(`YouTube videos API error: ${response.status}`);
      }
      const data: VideoDetailResponse = await response.json();
      if (data.items) {
        for (const item of data.items) {
          const thumbnail =
            item.snippet.thumbnails.high?.url ??
            item.snippet.thumbnails.medium?.url ??
            item.snippet.thumbnails.default?.url ??
            '';

          const locationDesc =
            item.recordingDetails?.locationDescription ?? null;
          let city: string | null = null;
          let country: string | null = null;

          if (
            item.recordingDetails?.location &&
            !city &&
            !country
          ) {
            // Will be geocoded later
          } else if (locationDesc) {
            const parsed =
              this.geocodingService.parseLocationDescription(locationDesc);
            city = parsed.city;
            country = parsed.country;
          }

          videos.push(
            new VideoModel(
              item.id,
              item.snippet.title,
              item.snippet.channelTitle,
              thumbnail,
              item.snippet.publishedAt,
              item.snippet.tags ?? [],
              city,
              country,
              item.recordingDetails?.location?.latitude ?? null,
              item.recordingDetails?.location?.longitude ?? null,
              item.recordingDetails?.recordingDate ?? null,
            ),
          );
        }
      }
    }

    return videos;
  }
}
