import type { Result } from '@/src/core/error/result';
import type { UseCase } from '@/src/core/usecases/usecase';
import type { Video } from '@/src/features/videos/domain/entities/video';
import type { VideosRepository } from '@/src/features/videos/domain/repositories/videos-repository';

export interface GetVideosByChannelParams {
  channelName: string;
}

export class GetVideosByChannel implements UseCase<Video[], GetVideosByChannelParams> {
  constructor(private readonly videosRepository: VideosRepository) {}

  execute(params: GetVideosByChannelParams): Promise<Result<Video[]>> {
    return this.videosRepository.getVideosByChannel(params.channelName);
  }
}
