import AsyncStorage from '@react-native-async-storage/async-storage';
import type { VideoData } from './youtubeApi';

const CACHE_KEY = 'youtube_videos_cache';
const CACHE_DURATION = 24 * 60 * 60 * 1000; // 24 hours

interface CacheData {
  videos: VideoData[];
  timestamp: number;
}

export async function saveToCache(videos: VideoData[]): Promise<void> {
  try {
    const data: CacheData = {
      videos,
      timestamp: Date.now(),
    };
    await AsyncStorage.setItem(CACHE_KEY, JSON.stringify(data));
  } catch (e) {
    console.error('Error saving to cache:', e);
  }
}

export async function getFromCache(): Promise<VideoData[] | null> {
  try {
    const raw = await AsyncStorage.getItem(CACHE_KEY);
    if (!raw) return null;

    const data: CacheData = JSON.parse(raw);
    if (Date.now() - data.timestamp > CACHE_DURATION) {
      return null;
    }
    return data.videos;
  } catch (e) {
    console.error('Error reading cache:', e);
    return null;
  }
}

export async function clearCache(): Promise<void> {
  try {
    await AsyncStorage.removeItem(CACHE_KEY);
  } catch (e) {
    console.error('Error clearing cache:', e);
  }
}

export async function isCacheValid(): Promise<boolean> {
  try {
    const raw = await AsyncStorage.getItem(CACHE_KEY);
    if (!raw) return false;

    const data: CacheData = JSON.parse(raw);
    return Date.now() - data.timestamp <= CACHE_DURATION;
  } catch {
    return false;
  }
}

export async function getCacheAge(): Promise<number | null> {
  try {
    const raw = await AsyncStorage.getItem(CACHE_KEY);
    if (!raw) return null;

    const data: CacheData = JSON.parse(raw);
    return Math.round((Date.now() - data.timestamp) / (60 * 1000));
  } catch {
    return null;
  }
}
