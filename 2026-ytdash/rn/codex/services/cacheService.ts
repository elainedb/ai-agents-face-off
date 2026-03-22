import AsyncStorage from '@react-native-async-storage/async-storage';

import type { VideoData } from '@/types/video';

const CACHE_KEY = 'youtube_videos_cache';
const CACHE_TTL_MS = 24 * 60 * 60 * 1000;

type CachePayload = {
  videos: VideoData[];
  timestamp: number;
};

export async function saveToCache(videos: VideoData[]) {
  const payload: CachePayload = {
    videos,
    timestamp: Date.now(),
  };

  await AsyncStorage.setItem(CACHE_KEY, JSON.stringify(payload));
}

export async function getFromCache() {
  const rawValue = await AsyncStorage.getItem(CACHE_KEY);
  if (!rawValue) {
    return null;
  }

  const parsedValue = JSON.parse(rawValue) as CachePayload;
  if (!isCacheValid(parsedValue.timestamp)) {
    await AsyncStorage.removeItem(CACHE_KEY);
    return null;
  }

  return parsedValue;
}

export async function clearCache() {
  await AsyncStorage.removeItem(CACHE_KEY);
}

export function isCacheValid(timestamp: number) {
  return Date.now() - timestamp < CACHE_TTL_MS;
}

export async function getCacheAge() {
  const rawValue = await AsyncStorage.getItem(CACHE_KEY);
  if (!rawValue) {
    return null;
  }

  const parsedValue = JSON.parse(rawValue) as CachePayload;
  return Math.round((Date.now() - parsedValue.timestamp) / 60000);
}
