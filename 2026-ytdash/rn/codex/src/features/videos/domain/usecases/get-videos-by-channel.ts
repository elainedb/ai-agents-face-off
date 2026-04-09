import { Result } from '@/src/core/error/result';
import { UseCase } from '@/src/core/usecases/usecase';
import { Video } from '@/src/features/videos/domain/entities/video';
import { VideosRepository } from '@/src/features/videos/domain/repositories/videos-repository';

interface GetVideosByChannelParams {
  channelName: string;
}

export class GetVideosByChannel implements UseCase<Video[], GetVideosByChannelParams> {
  constructor(private readonly videosRepository: VideosRepository) {}

  execute(params: GetVideosByChannelParams): Promise<Result<Video[]>> {
    return this.videosRepository.getVideosByChannel(params.channelName);
  }
}
