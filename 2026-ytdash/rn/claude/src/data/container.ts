import { AsyncStorageCacheStore, CacheStore } from './cacheStore';
import { HttpVideoRepository, VideoRepository } from './videoRepository';

export type Container = {
  cacheStore: CacheStore;
  videoRepository: VideoRepository;
};

function createContainer(): Container {
  const cacheStore = new AsyncStorageCacheStore();
  const videoRepository = new HttpVideoRepository(cacheStore);
  return { cacheStore, videoRepository };
}

export const container: Container = createContainer();
