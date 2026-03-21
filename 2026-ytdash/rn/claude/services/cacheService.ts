import AsyncStorage from '@react-native-async-storage/async-storage';
import type { VideoData } from './youtubeApi';

const CACHE_KEY = 'youtube_videos_cache';
const CACHE_EXPIRATION = 24 * 60 * 60 * 1000; // 24 hours

interface CacheData {
  videos: VideoData[];
  timestamp: number;
}

export async function saveToCache(videos: VideoData[]): Promise<void> {
  try {
    const cacheData: CacheData = {
      videos,
      timestamp: Date.now(),
    };
    await AsyncStorage.setItem(CACHE_KEY, JSON.stringify(cacheData));
  } catch (error) {
    console.error('Error saving to cache:', error);
  }
}

export async function getFromCache(): Promise<VideoData[] | null> {
  try {
    const raw = await AsyncStorage.getItem(CACHE_KEY);
    if (!raw) return null;

    const cacheData: CacheData = JSON.parse(raw);
    if (Date.now() - cacheData.timestamp > CACHE_EXPIRATION) {
      return null;
    }

    return cacheData.videos;
  } catch (error) {
    console.error('Error reading cache:', error);
    return null;
  }
}

export async function clearCache(): Promise<void> {
  try {
    await AsyncStorage.removeItem(CACHE_KEY);
  } catch (error) {
    console.error('Error clearing cache:', error);
  }
}

export async function isCacheValid(): Promise<boolean> {
  try {
    const raw = await AsyncStorage.getItem(CACHE_KEY);
    if (!raw) return false;

    const cacheData: CacheData = JSON.parse(raw);
    return Date.now() - cacheData.timestamp <= CACHE_EXPIRATION;
  } catch {
    return false;
  }
}

export async function getCacheAge(): Promise<number | null> {
  try {
    const raw = await AsyncStorage.getItem(CACHE_KEY);
    if (!raw) return null;

    const cacheData: CacheData = JSON.parse(raw);
    return Math.round((Date.now() - cacheData.timestamp) / (60 * 1000));
  } catch {
    return null;
  }
}
