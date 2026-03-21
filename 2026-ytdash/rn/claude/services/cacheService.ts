import AsyncStorage from '@react-native-async-storage/async-storage';
import { fetchAllVideos as fetchFreshVideos, enhanceLocationData, type VideoData } from './youtubeApi';

const CACHE_KEY = 'youtube_videos_cache';
const CACHE_DURATION = 24 * 60 * 60 * 1000; // 24 hours

interface CacheData {
  videos: VideoData[];
  timestamp: number;
}

export async function saveToCache(videos: VideoData[]): Promise<void> {
  const cacheData: CacheData = {
    videos,
    timestamp: Date.now(),
  };
  await AsyncStorage.setItem(CACHE_KEY, JSON.stringify(cacheData));
}

export async function getFromCache(): Promise<VideoData[] | null> {
  try {
    const raw = await AsyncStorage.getItem(CACHE_KEY);
    if (!raw) return null;

    const cacheData: CacheData = JSON.parse(raw);
    if (Date.now() - cacheData.timestamp > CACHE_DURATION) {
      return null;
    }
    return cacheData.videos;
  } catch {
    return null;
  }
}

export async function clearCache(): Promise<void> {
  await AsyncStorage.removeItem(CACHE_KEY);
}

export async function isCacheValid(): Promise<boolean> {
  try {
    const raw = await AsyncStorage.getItem(CACHE_KEY);
    if (!raw) return false;
    const cacheData: CacheData = JSON.parse(raw);
    return Date.now() - cacheData.timestamp <= CACHE_DURATION;
  } catch {
    return false;
  }
}

export async function getCacheAge(): Promise<number> {
  try {
    const raw = await AsyncStorage.getItem(CACHE_KEY);
    if (!raw) return -1;
    const cacheData: CacheData = JSON.parse(raw);
    return Math.floor((Date.now() - cacheData.timestamp) / 60000);
  } catch {
    return -1;
  }
}

export async function fetchAllVideos(forceRefresh = false): Promise<VideoData[]> {
  if (!forceRefresh) {
    const cached = await getFromCache();
    if (cached) {
      // Enhance location data in background and update cache
      enhanceLocationData(cached).then((enhanced) => {
        saveToCache(enhanced);
      });
      return cached;
    }
  }

  const videos = await fetchFreshVideos();
  await saveToCache(videos);

  // Enhance location data and update cache
  const enhanced = await enhanceLocationData(videos);
  await saveToCache(enhanced);

  return enhanced;
}
