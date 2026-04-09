import type { Result } from '@/src/core/error/result';
import type { UseCase } from '@/src/core/usecases/usecase';
import type { Video } from '@/src/features/videos/domain/entities/video';
import type { VideosRepository } from '@/src/features/videos/domain/repositories/videos-repository';

export interface GetVideosParams {
  channelIds: string[];
  forceRefresh: boolean;
}

export class GetVideos implements UseCase<Video[], GetVideosParams> {
  constructor(private readonly videosRepository: VideosRepository) {}

  execute(params: GetVideosParams): Promise<Result<Video[]>> {
    return this.videosRepository.getVideosFromChannels(params.channelIds, params.forceRefresh);
  }
}
