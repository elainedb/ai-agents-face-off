import { Result } from '@/src/core/error/result';
import { UseCase } from '@/src/core/usecases/usecase';
import { Video } from '@/src/features/videos/domain/entities/video';
import { VideosRepository } from '@/src/features/videos/domain/repositories/videos-repository';

interface GetVideosParams {
  channelIds: string[];
  forceRefresh: boolean;
}

export class GetVideos implements UseCase<Video[], GetVideosParams> {
  constructor(private readonly videosRepository: VideosRepository) {}

  execute(params: GetVideosParams): Promise<Result<Video[]>> {
    return this.videosRepository.getVideosFromChannels(params.channelIds, params.forceRefresh);
  }
}
