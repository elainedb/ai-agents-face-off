import { CacheException, ServerException } from '../../../../core/error/exceptions';
import { Result } from '../../../../core/error/result';
import { Video } from '../../domain/entities/video';
import { VideosRepository } from '../../domain/repositories/videos-repository';
import { VideosLocalDataSource } from '../datasources/videos-local-datasource';
import { VideosRemoteDataSource } from '../datasources/videos-remote-datasource';

export class VideosRepositoryImpl implements VideosRepository {
  constructor(
    private remoteDataSource: VideosRemoteDataSource,
    private localDataSource: VideosLocalDataSource,
  ) {}

  async getVideosFromChannels(
    channelIds: string[],
    forceRefresh: boolean = false,
  ): Promise<Result<Video[]>> {
    if (!forceRefresh) {
      try {
        const isValid = await this.localDataSource.isCacheValid();
        if (isValid) {
          const cached = await this.localDataSource.getCachedVideos();
          if (cached.length > 0) {
            return { ok: true, data: cached.map((v) => v.toEntity()) };
          }
        }
      } catch {
        // Cache read failed, proceed to remote
      }
    }

    try {
      const videos = await this.remoteDataSource.getVideosFromChannels(channelIds);
      try {
        await this.localDataSource.cacheVideos(videos);
      } catch {
        // Cache write failed, still return data
      }
      return { ok: true, data: videos.map((v) => v.toEntity()) };
    } catch (error: unknown) {
      if (error instanceof ServerException) {
        // Fallback to cache
        try {
          const cached = await this.localDataSource.getCachedVideos();
          if (cached.length > 0) {
            return { ok: true, data: cached.map((v) => v.toEntity()) };
          }
        } catch {
          // Cache also failed
        }
        return { ok: false, error: { type: 'server', message: error.message } };
      }
      return {
        ok: false,
        error: { type: 'unexpected', message: error instanceof Error ? error.message : String(error) },
      };
    }
  }

  async getVideosByChannel(channelName: string): Promise<Result<Video[]>> {
    try {
      const videos = await this.localDataSource.getVideosByChannel(channelName);
      return { ok: true, data: videos.map((v) => v.toEntity()) };
    } catch (error: unknown) {
      if (error instanceof CacheException) {
        return { ok: false, error: { type: 'cache', message: error.message } };
      }
      return { ok: false, error: { type: 'unexpected', message: String(error) } };
    }
  }

  async getVideosByCountry(country: string): Promise<Result<Video[]>> {
    try {
      const videos = await this.localDataSource.getVideosByCountry(country);
      return { ok: true, data: videos.map((v) => v.toEntity()) };
    } catch (error: unknown) {
      if (error instanceof CacheException) {
        return { ok: false, error: { type: 'cache', message: error.message } };
      }
      return { ok: false, error: { type: 'unexpected', message: String(error) } };
    }
  }

  async clearCache(): Promise<Result<void>> {
    try {
      await this.localDataSource.clearCache();
      return { ok: true, data: undefined };
    } catch (error: unknown) {
      if (error instanceof CacheException) {
        return { ok: false, error: { type: 'cache', message: error.message } };
      }
      return { ok: false, error: { type: 'unexpected', message: String(error) } };
    }
  }
}
