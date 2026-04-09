import { ServerException } from '@/src/core/error/exceptions';
import { failure, failureFromUnknown, Result, success } from '@/src/core/error/result';
import { VideoModel } from '@/src/features/videos/data/models/video-model';
import { VideosLocalDataSource } from '@/src/features/videos/data/datasources/videos-local-datasource';
import { VideosRemoteDataSource } from '@/src/features/videos/data/datasources/videos-remote-datasource';
import { Video } from '@/src/features/videos/domain/entities/video';
import { VideosRepository } from '@/src/features/videos/domain/repositories/videos-repository';

export class VideosRepositoryImpl implements VideosRepository {
  constructor(
    private readonly remoteDataSource: VideosRemoteDataSource,
    private readonly localDataSource: VideosLocalDataSource,
  ) {}

  async getVideosFromChannels(
    channelIds: string[],
    forceRefresh = false,
  ): Promise<Result<Video[]>> {
    try {
      if (!forceRefresh) {
        const isCacheValid = await this.localDataSource.isCacheValid();
        if (isCacheValid) {
          const cachedVideos = await this.localDataSource.getCachedVideos();
          if (cachedVideos.length > 0) {
            return success(this.toEntities(cachedVideos));
          }
        }
      }

      const videos = await this.remoteDataSource.getVideosFromChannels(channelIds);
      await this.localDataSource.cacheVideos(videos);
      return success(this.toEntities(videos));
    } catch (error) {
      if (error instanceof ServerException) {
        try {
          const cachedVideos = await this.localDataSource.getCachedVideos();
          if (cachedVideos.length > 0) {
            return success(this.toEntities(cachedVideos));
          }
        } catch {
          return failure({ type: 'server', message: error.message });
        }

        return failure({ type: 'server', message: error.message });
      }

      return failure(failureFromUnknown(error));
    }
  }

  async getVideosByChannel(channelName: string): Promise<Result<Video[]>> {
    try {
      return success(this.toEntities(await this.localDataSource.getVideosByChannel(channelName)));
    } catch (error) {
      return failure(failureFromUnknown(error));
    }
  }

  async getVideosByCountry(country: string): Promise<Result<Video[]>> {
    try {
      return success(this.toEntities(await this.localDataSource.getVideosByCountry(country)));
    } catch (error) {
      return failure(failureFromUnknown(error));
    }
  }

  async clearCache(): Promise<Result<void>> {
    try {
      await this.localDataSource.clearCache();
      return success(undefined);
    } catch (error) {
      return failure(failureFromUnknown(error));
    }
  }

  private toEntities(videos: VideoModel[]): Video[] {
    return videos.map((video) => video.toEntity());
  }
}
