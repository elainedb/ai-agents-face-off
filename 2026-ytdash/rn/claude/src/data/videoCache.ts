import AsyncStorage from '@react-native-async-storage/async-storage';

import { Video } from '../domain/types';

const CACHE_KEY = 'ytdash:videos:v1';

// The local persisted store — the UI's single source of truth (constitution §1.5). Replaced
// wholesale on every successful refresh; read back verbatim on cache-fallback / cold start.
export async function saveVideos(videos: Video[]): Promise<void> {
  await AsyncStorage.setItem(CACHE_KEY, JSON.stringify(videos));
}

export async function loadVideos(): Promise<Video[] | null> {
  const raw = await AsyncStorage.getItem(CACHE_KEY);
  if (!raw) return null;
  try {
    const parsed = JSON.parse(raw);
    return Array.isArray(parsed) ? (parsed as Video[]) : null;
  } catch {
    return null;
  }
}

export async function clearVideos(): Promise<void> {
  await AsyncStorage.removeItem(CACHE_KEY);
}
