import AsyncStorage from '@react-native-async-storage/async-storage';
import type { Video } from '../domain/models';

const CACHE_KEY = 'ytdash.videoCache.v1';

type CachePayload = {
  videos: Video[];
  fetchedAt: string;
};

export async function readCache(): Promise<Video[] | null> {
  const raw = await AsyncStorage.getItem(CACHE_KEY);
  if (!raw) return null;
  try {
    const parsed = JSON.parse(raw) as CachePayload;
    return parsed.videos ?? null;
  } catch {
    return null;
  }
}

export async function writeCache(videos: Video[]): Promise<void> {
  const payload: CachePayload = { videos, fetchedAt: new Date().toISOString() };
  await AsyncStorage.setItem(CACHE_KEY, JSON.stringify(payload));
}
