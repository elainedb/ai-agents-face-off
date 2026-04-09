import { CacheException, NetworkException, ServerException } from '@/src/core/error/exceptions';
import { failure, success, type Result } from '@/src/core/error/result';
import type { Video } from '@/src/features/videos/domain/entities/video';
import type { VideosRepository } from '@/src/features/videos/domain/repositories/videos-repository';
import { VideosLocalDataSource } from '@/src/features/videos/data/datasources/videos-local-datasource';
import { VideosRemoteDataSource } from '@/src/features/videos/data/datasources/videos-remote-datasource';

export class VideosRepositoryImpl implements VideosRepository {
  constructor(
    private readonly videosRemoteDataSource: VideosRemoteDataSource,
    private readonly videosLocalDataSource: VideosLocalDataSource
  ) {}

  async getVideosFromChannels(channelIds: string[], forceRefresh = false): Promise<Result<Video[]>> {
    try {
      const cachedVideos = await this.videosLocalDataSource.getCachedVideos();
      const isCacheValid = await this.videosLocalDataSource.isCacheValid();

      if (!forceRefresh && isCacheValid && cachedVideos.length > 0) {
        return success(cachedVideos.map((video) => video.toEntity()));
      }

      const remoteVideos = await this.videosRemoteDataSource.getVideosFromChannels(channelIds);
      await this.videosLocalDataSource.cacheVideos(remoteVideos);
      return success(remoteVideos.map((video) => video.toEntity()));
    } catch (error) {
      try {
        const cachedVideos = await this.videosLocalDataSource.getCachedVideos();
        if (cachedVideos.length > 0) {
          return success(cachedVideos.map((video) => video.toEntity()));
        }
      } catch {
        // Ignore cache fallback errors and map the original failure below.
      }

      return this.mapError<Video[]>(error);
    }
  }

  async getVideosByChannel(channelName: string): Promise<Result<Video[]>> {
    try {
      const videos = await this.videosLocalDataSource.getVideosByChannel(channelName);
      return success(videos.map((video) => video.toEntity()));
    } catch (error) {
      return this.mapError<Video[]>(error);
    }
  }

  async getVideosByCountry(country: string): Promise<Result<Video[]>> {
    try {
      const videos = await this.videosLocalDataSource.getVideosByCountry(country);
      return success(videos.map((video) => video.toEntity()));
    } catch (error) {
      return this.mapError<Video[]>(error);
    }
  }

  async clearCache(): Promise<Result<void>> {
    try {
      await this.videosLocalDataSource.clearCache();
      return success(undefined);
    } catch (error) {
      return this.mapError<void>(error);
    }
  }

  private mapError<T>(error: unknown): Result<T> {
    if (error instanceof ServerException) {
      return failure({ type: 'server', message: error.message });
    }

    if (error instanceof NetworkException) {
      return failure({ type: 'network', message: error.message });
    }

    if (error instanceof CacheException) {
      return failure({ type: 'cache', message: error.message });
    }

    if (error instanceof Error) {
      return failure({ type: 'unexpected', message: error.message });
    }

    return failure({ type: 'unexpected', message: 'An unexpected video error occurred.' });
  }
}
