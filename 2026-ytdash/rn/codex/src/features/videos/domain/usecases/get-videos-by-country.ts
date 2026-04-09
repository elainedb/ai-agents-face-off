import { Result } from '@/src/core/error/result';
import { UseCase } from '@/src/core/usecases/usecase';
import { Video } from '@/src/features/videos/domain/entities/video';
import { VideosRepository } from '@/src/features/videos/domain/repositories/videos-repository';

interface GetVideosByCountryParams {
  country: string;
}

export class GetVideosByCountry implements UseCase<Video[], GetVideosByCountryParams> {
  constructor(private readonly videosRepository: VideosRepository) {}

  execute(params: GetVideosByCountryParams): Promise<Result<Video[]>> {
    return this.videosRepository.getVideosByCountry(params.country);
  }
}
