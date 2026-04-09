import type { Result } from '@/src/core/error/result';
import type { Video } from '@/src/features/videos/domain/entities/video';

export interface VideosRepository {
  getVideosFromChannels(channelIds: string[], forceRefresh?: boolean): Promise<Result<Video[]>>;
  getVideosByChannel(channelName: string): Promise<Result<Video[]>>;
  getVideosByCountry(country: string): Promise<Result<Video[]>>;
  clearCache(): Promise<Result<void>>;
}
