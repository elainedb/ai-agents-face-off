import { Result } from '../../../../core/error/result';
import { UseCase } from '../../../../core/usecases/usecase';
import { Video } from '../entities/video';
import { VideosRepository } from '../repositories/videos-repository';

export interface GetVideosByChannelParams {
  channelName: string;
}

export class GetVideosByChannel implements UseCase<Video[], GetVideosByChannelParams> {
  constructor(private repository: VideosRepository) {}

  async execute(params: GetVideosByChannelParams): Promise<Result<Video[]>> {
    return this.repository.getVideosByChannel(params.channelName);
  }
}
