import { z } from 'zod';

import { youtubeApiKey } from '@/src/config/api-config';
import { NetworkException, ServerException } from '@/src/core/error/exceptions';
import { VideoModel, videoModelSchema } from '@/src/features/videos/data/models/video-model';
import { GeocodingService } from '@/src/features/videos/data/services/geocoding-service';

const searchResponseSchema = z.object({
  nextPageToken: z.string().optional(),
  items: z.array(
    z.object({
      id: z.object({
        videoId: z.string(),
      }),
    })
  ),
});

const videosResponseSchema = z.object({
  items: z.array(
    z.object({
      id: z.string(),
      snippet: z.object({
        title: z.string(),
        channelTitle: z.string(),
        publishedAt: z.string(),
        tags: z.array(z.string()).optional(),
        thumbnails: z.object({
          high: z.object({ url: z.string().url() }).optional(),
          medium: z.object({ url: z.string().url() }).optional(),
          default: z.object({ url: z.string().url() }).optional(),
        }),
      }),
      recordingDetails: z
        .object({
          recordingDate: z.string().optional(),
          locationDescription: z.string().optional(),
          location: z
            .object({
              latitude: z.number(),
              longitude: z.number(),
            })
            .optional(),
        })
        .optional(),
    })
  ),
});

export class VideosRemoteDataSource {
  constructor(private readonly geocodingService: GeocodingService) {}

  async getVideosFromChannels(channelIds: string[]): Promise<VideoModel[]> {
    const idGroups = await Promise.all(channelIds.map((channelId) => this.fetchAllVideoIdsForChannel(channelId)));
    const uniqueVideoIds = [...new Set(idGroups.flat())];

    const detailedVideos: VideoModel[] = [];
    for (let index = 0; index < uniqueVideoIds.length; index += 50) {
      const batch = uniqueVideoIds.slice(index, index + 50);
      const batchVideos = await this.fetchVideoDetails(batch);
      detailedVideos.push(...batchVideos);
    }

    const geocodedVideos: VideoModel[] = [];
    for (const video of detailedVideos) {
      if (video.latitude == null || video.longitude == null) {
        geocodedVideos.push(video);
        continue;
      }

      const resolvedLocation = await this.geocodingService.reverseGeocode(
        video.latitude,
        video.longitude,
        video.locationDescription
      );

      geocodedVideos.push(video.withResolvedLocation(resolvedLocation));
    }

    return geocodedVideos.sort(
      (left, right) => new Date(right.publishedAt).getTime() - new Date(left.publishedAt).getTime()
    );
  }

  private async fetchAllVideoIdsForChannel(channelId: string): Promise<string[]> {
    const videoIds: string[] = [];
    let nextPageToken: string | undefined;

    do {
      const query = new URLSearchParams({
        part: 'snippet',
        channelId,
        order: 'date',
        maxResults: '50',
        type: 'video',
        key: youtubeApiKey,
      });

      if (nextPageToken) {
        query.set('pageToken', nextPageToken);
      }

      const response = await fetch(`https://www.googleapis.com/youtube/v3/search?${query.toString()}`);
      if (!response.ok) {
        throw new ServerException(`YouTube search request failed with status ${response.status}.`);
      }

      const parsed = searchResponseSchema.parse(await response.json());
      videoIds.push(...parsed.items.map((item) => item.id.videoId));
      nextPageToken = parsed.nextPageToken;
    } while (nextPageToken);

    return videoIds;
  }

  private async fetchVideoDetails(videoIds: string[]): Promise<VideoModel[]> {
    if (videoIds.length === 0) {
      return [];
    }

    const query = new URLSearchParams({
      part: 'snippet,recordingDetails',
      id: videoIds.join(','),
      key: youtubeApiKey,
    });

    try {
      const response = await fetch(`https://www.googleapis.com/youtube/v3/videos?${query.toString()}`);
      if (!response.ok) {
        throw new ServerException(`YouTube videos request failed with status ${response.status}.`);
      }

      const parsed = videosResponseSchema.parse(await response.json());
      return parsed.items.map((item) => {
        const model = videoModelSchema.parse({
          id: item.id,
          title: item.snippet.title,
          channelName: item.snippet.channelTitle,
          thumbnailUrl:
            item.snippet.thumbnails.high?.url ??
            item.snippet.thumbnails.medium?.url ??
            item.snippet.thumbnails.default?.url,
          publishedAt: item.snippet.publishedAt,
          tags: item.snippet.tags ?? [],
          city: null,
          country: null,
          latitude: item.recordingDetails?.location?.latitude ?? null,
          longitude: item.recordingDetails?.location?.longitude ?? null,
          recordingDate: item.recordingDetails?.recordingDate ?? null,
          locationDescription: item.recordingDetails?.locationDescription ?? null,
        });

        return new VideoModel(
          model.id,
          model.title,
          model.channelName,
          model.thumbnailUrl,
          model.publishedAt,
          model.tags,
          model.city,
          model.country,
          model.latitude,
          model.longitude,
          model.recordingDate,
          model.locationDescription ?? null
        );
      });
    } catch (error) {
      if (error instanceof z.ZodError) {
        throw new ServerException(`Invalid YouTube API response: ${error.message}`);
      }

      if (error instanceof ServerException) {
        throw error;
      }

      if (error instanceof Error) {
        throw new NetworkException(error.message);
      }

      throw new ServerException('Unable to load videos from YouTube.');
    }
  }
}
