import AsyncStorage from '@react-native-async-storage/async-storage';

import type { VideoData } from '@/services/youtubeApi';

const CACHE_KEY = 'youtube_videos_cache';
const CACHE_TTL_MS = 24 * 60 * 60 * 1000;

type CachePayload = {
  videos: VideoData[];
  timestamp: number;
};

export async function saveToCache(videos: VideoData[]) {
  const payload: CachePayload = {
    timestamp: Date.now(),
    videos,
  };

  await AsyncStorage.setItem(CACHE_KEY, JSON.stringify(payload));
}

export async function getFromCache(): Promise<VideoData[] | null> {
  const rawValue = await AsyncStorage.getItem(CACHE_KEY);
  if (!rawValue) {
    return null;
  }

  const parsedValue = JSON.parse(rawValue) as CachePayload;
  if (Date.now() - parsedValue.timestamp > CACHE_TTL_MS) {
    await AsyncStorage.removeItem(CACHE_KEY);
    return null;
  }

  return parsedValue.videos;
}

export async function clearCache() {
  await AsyncStorage.removeItem(CACHE_KEY);
}

export async function isCacheValid() {
  const rawValue = await AsyncStorage.getItem(CACHE_KEY);
  if (!rawValue) {
    return false;
  }

  const parsedValue = JSON.parse(rawValue) as CachePayload;
  return Date.now() - parsedValue.timestamp <= CACHE_TTL_MS;
}

export async function getCacheAge() {
  const rawValue = await AsyncStorage.getItem(CACHE_KEY);
  if (!rawValue) {
    return null;
  }

  const parsedValue = JSON.parse(rawValue) as CachePayload;
  return Math.floor((Date.now() - parsedValue.timestamp) / (60 * 1000));
}
