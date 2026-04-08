import { CacheException, ServerException } from '@/src/core/error/exceptions';
import { err, ok, type Result } from '@/src/core/error/result';
import type { Video } from '@/src/features/videos/domain/entities/video';
import type { VideosRepository } from '@/src/features/videos/domain/repositories/videos-repository';
import { VideosLocalDataSource } from '@/src/features/videos/data/datasources/videos-local-datasource';
import { VideosRemoteDataSource } from '@/src/features/videos/data/datasources/videos-remote-datasource';

export class VideosRepositoryImpl implements VideosRepository {
  constructor(
    private readonly videosRemoteDataSource: VideosRemoteDataSource,
    private readonly videosLocalDataSource: VideosLocalDataSource
  ) {}

  private toEntities(models: { toEntity(): Video }[]) {
    return models.map((model) => model.toEntity());
  }

  async getVideosFromChannels(
    channelIds: string[],
    forceRefresh = false
  ): Promise<Result<Video[]>> {
    try {
      const isCacheValid = !forceRefresh && (await this.videosLocalDataSource.isCacheValid());
      const cachedVideos = await this.videosLocalDataSource.getCachedVideos();

      if (isCacheValid && cachedVideos.length > 0) {
        return ok(this.toEntities(cachedVideos));
      }

      const remoteVideos = await this.videosRemoteDataSource.getVideosFromChannels(channelIds);
      await this.videosLocalDataSource.cacheVideos(remoteVideos);
      return ok(this.toEntities(remoteVideos));
    } catch (error) {
      if (error instanceof ServerException) {
        try {
          const cachedVideos = await this.videosLocalDataSource.getCachedVideos();
          if (cachedVideos.length > 0) {
            return ok(this.toEntities(cachedVideos));
          }
        } catch {
          return err({
            type: 'server',
            message: error.message,
          });
        }
      }

      if (error instanceof CacheException) {
        return err({
          type: 'cache',
          message: error.message,
        });
      }

      return err({
        type: 'server',
        message: error instanceof Error ? error.message : 'Unable to load videos.',
      });
    }
  }

  async getVideosByChannel(channelName: string): Promise<Result<Video[]>> {
    try {
      return ok(this.toEntities(await this.videosLocalDataSource.getVideosByChannel(channelName)));
    } catch (error) {
      return err({
        type: 'cache',
        message: error instanceof Error ? error.message : 'Unable to filter videos by channel.',
      });
    }
  }

  async getVideosByCountry(country: string): Promise<Result<Video[]>> {
    try {
      return ok(this.toEntities(await this.videosLocalDataSource.getVideosByCountry(country)));
    } catch (error) {
      return err({
        type: 'cache',
        message: error instanceof Error ? error.message : 'Unable to filter videos by country.',
      });
    }
  }

  async clearCache(): Promise<Result<void>> {
    try {
      await this.videosLocalDataSource.clearCache();
      return ok(undefined);
    } catch (error) {
      return err({
        type: 'cache',
        message: error instanceof Error ? error.message : 'Unable to clear cache.',
      });
    }
  }
}
