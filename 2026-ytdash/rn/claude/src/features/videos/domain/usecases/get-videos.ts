import type { UseCase } from '@/src/core/usecases/usecase';
import type { Result } from '@/src/core/error/result';
import type { Video } from '../entities/video';
import type { VideosRepository } from '../repositories/videos-repository';

interface GetVideosParams {
  channelIds: string[];
  forceRefresh: boolean;
}

export class GetVideos implements UseCase<Video[], GetVideosParams> {
  constructor(private readonly repository: VideosRepository) {}

  async execute(params: GetVideosParams): Promise<Result<Video[]>> {
    return this.repository.getVideosFromChannels(params.channelIds, params.forceRefresh);
  }
}
