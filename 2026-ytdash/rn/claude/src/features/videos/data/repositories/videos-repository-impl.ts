import type { Result } from '@/src/core/error/result';
import type { Video } from '../../domain/entities/video';
import type { VideosRepository } from '../../domain/repositories/videos-repository';
import type { VideosRemoteDataSource } from '../datasources/videos-remote-datasource';
import type { VideosLocalDataSource } from '../datasources/videos-local-datasource';
import { ServerException, CacheException } from '@/src/core/error/exceptions';

export class VideosRepositoryImpl implements VideosRepository {
  constructor(
    private readonly remote: VideosRemoteDataSource,
    private readonly local: VideosLocalDataSource,
  ) {}

  async getVideosFromChannels(
    channelIds: string[],
    forceRefresh = false,
  ): Promise<Result<Video[]>> {
    try {
      if (!forceRefresh) {
        const cacheValid = await this.local.isCacheValid();
        if (cacheValid) {
          const cached = await this.local.getCachedVideos();
          if (cached.length > 0) {
            return { ok: true, data: cached.map((m) => m.toEntity()) };
          }
        }
      }

      const models = await this.remote.getVideosFromChannels(channelIds);
      await this.local.cacheVideos(models);
      return { ok: true, data: models.map((m) => m.toEntity()) };
    } catch (error) {
      if (error instanceof ServerException) {
        try {
          const cached = await this.local.getCachedVideos();
          if (cached.length > 0) {
            return { ok: true, data: cached.map((m) => m.toEntity()) };
          }
        } catch {
          // cache also failed
        }
        return { ok: false, error: { type: 'server', message: error.message } };
      }

      if (error instanceof CacheException) {
        return { ok: false, error: { type: 'cache', message: error.message } };
      }

      const message = error instanceof Error ? error.message : 'Unexpected error';
      return { ok: false, error: { type: 'unexpected', message } };
    }
  }

  async getVideosByChannel(channelName: string): Promise<Result<Video[]>> {
    try {
      const models = await this.local.getVideosByChannel(channelName);
      return { ok: true, data: models.map((m) => m.toEntity()) };
    } catch (error) {
      const message = error instanceof Error ? error.message : 'Cache error';
      return { ok: false, error: { type: 'cache', message } };
    }
  }

  async getVideosByCountry(country: string): Promise<Result<Video[]>> {
    try {
      const models = await this.local.getVideosByCountry(country);
      return { ok: true, data: models.map((m) => m.toEntity()) };
    } catch (error) {
      const message = error instanceof Error ? error.message : 'Cache error';
      return { ok: false, error: { type: 'cache', message } };
    }
  }

  async clearCache(): Promise<Result<void>> {
    try {
      await this.local.clearCache();
      return { ok: true, data: undefined };
    } catch (error) {
      const message = error instanceof Error ? error.message : 'Cache clear error';
      return { ok: false, error: { type: 'cache', message } };
    }
  }
}
