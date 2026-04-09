import { Result } from '@/src/core/error/result';
import { ServerException } from '@/src/core/error/exceptions';
import { Video } from '../../domain/entities/video';
import { VideosRepository } from '../../domain/repositories/videos-repository';
import { VideosRemoteDataSource } from '../datasources/videos-remote-datasource';
import { VideosLocalDataSource } from '../datasources/videos-local-datasource';

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
        const cacheValid = await this.localDataSource.isCacheValid();
        if (cacheValid) {
          const cached = await this.localDataSource.getCachedVideos();
          if (cached.length > 0) {
            return { ok: true, data: cached.map((v) => v.toEntity()) };
          }
        }
      }

      const remoteVideos =
        await this.remoteDataSource.getVideosFromChannels(channelIds);
      await this.localDataSource.cacheVideos(remoteVideos);
      return { ok: true, data: remoteVideos.map((v) => v.toEntity()) };
    } catch (error) {
      if (error instanceof ServerException) {
        try {
          const cached = await this.localDataSource.getCachedVideos();
          if (cached.length > 0) {
            return { ok: true, data: cached.map((v) => v.toEntity()) };
          }
        } catch {
          // Cache also failed
        }
      }
      return {
        ok: false,
        error: {
          type: 'server',
          message:
            error instanceof Error ? error.message : 'Failed to fetch videos',
        },
      };
    }
  }

  async getVideosByChannel(channelName: string): Promise<Result<Video[]>> {
    try {
      const videos =
        await this.localDataSource.getVideosByChannel(channelName);
      return { ok: true, data: videos.map((v) => v.toEntity()) };
    } catch (error) {
      return {
        ok: false,
        error: {
          type: 'cache',
          message:
            error instanceof Error
              ? error.message
              : 'Failed to get videos by channel',
        },
      };
    }
  }

  async getVideosByCountry(country: string): Promise<Result<Video[]>> {
    try {
      const videos =
        await this.localDataSource.getVideosByCountry(country);
      return { ok: true, data: videos.map((v) => v.toEntity()) };
    } catch (error) {
      return {
        ok: false,
        error: {
          type: 'cache',
          message:
            error instanceof Error
              ? error.message
              : 'Failed to get videos by country',
        },
      };
    }
  }

  async clearCache(): Promise<Result<void>> {
    try {
      await this.localDataSource.clearCache();
      return { ok: true, data: undefined };
    } catch (error) {
      return {
        ok: false,
        error: {
          type: 'cache',
          message:
            error instanceof Error ? error.message : 'Failed to clear cache',
        },
      };
    }
  }
}
