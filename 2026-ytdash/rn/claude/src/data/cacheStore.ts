import AsyncStorage from '@react-native-async-storage/async-storage';
import { Video } from '../domain/types';

const CACHE_KEY = 'ytdash:videoCache:v1';

export type VideoCache = {
  videos: Video[];
  fetchedAt: number;
};

export interface CacheStore {
  read(): Promise<VideoCache | null>;
  write(videos: Video[], fetchedAt: number): Promise<void>;
  clear(): Promise<void>;
}

export class AsyncStorageCacheStore implements CacheStore {
  async read(): Promise<VideoCache | null> {
    const raw = await AsyncStorage.getItem(CACHE_KEY);
    if (!raw) return null;
    try {
      return JSON.parse(raw) as VideoCache;
    } catch {
      return null;
    }
  }

  async write(videos: Video[], fetchedAt: number): Promise<void> {
    const cache: VideoCache = { videos, fetchedAt };
    await AsyncStorage.setItem(CACHE_KEY, JSON.stringify(cache));
  }

  async clear(): Promise<void> {
    await AsyncStorage.removeItem(CACHE_KEY);
  }
}
