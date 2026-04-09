import type { Result } from '@/src/core/error/result';
import type { UseCase } from '@/src/core/usecases/usecase';
import type { Video } from '@/src/features/videos/domain/entities/video';
import type { VideosRepository } from '@/src/features/videos/domain/repositories/videos-repository';

export interface GetVideosByCountryParams {
  country: string;
}

export class GetVideosByCountry implements UseCase<Video[], GetVideosByCountryParams> {
  constructor(private readonly videosRepository: VideosRepository) {}

  execute(params: GetVideosByCountryParams): Promise<Result<Video[]>> {
    return this.videosRepository.getVideosByCountry(params.country);
  }
}
