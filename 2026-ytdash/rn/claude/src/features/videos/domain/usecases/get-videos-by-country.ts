import type { UseCase } from '@/src/core/usecases/usecase';
import type { Result } from '@/src/core/error/result';
import type { Video } from '../entities/video';
import type { VideosRepository } from '../repositories/videos-repository';

interface GetVideosByCountryParams {
  country: string;
}

export class GetVideosByCountry implements UseCase<Video[], GetVideosByCountryParams> {
  constructor(private readonly repository: VideosRepository) {}

  async execute(params: GetVideosByCountryParams): Promise<Result<Video[]>> {
    return this.repository.getVideosByCountry(params.country);
  }
}
