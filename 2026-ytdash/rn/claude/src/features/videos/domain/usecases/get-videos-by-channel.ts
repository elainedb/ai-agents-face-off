import type { UseCase } from '@/src/core/usecases/usecase';
import type { Result } from '@/src/core/error/result';
import type { Video } from '../entities/video';
import type { VideosRepository } from '../repositories/videos-repository';

interface GetVideosByChannelParams {
  channelName: string;
}

export class GetVideosByChannel implements UseCase<Video[], GetVideosByChannelParams> {
  constructor(private readonly repository: VideosRepository) {}

  async execute(params: GetVideosByChannelParams): Promise<Result<Video[]>> {
    return this.repository.getVideosByChannel(params.channelName);
  }
}
