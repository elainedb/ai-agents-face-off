import AsyncStorage from '@react-native-async-storage/async-storage';

import { Video } from '../domain/types';

// Local persistence — the source of truth the UI reads from (constitution §1.5). The last good list
// is written on every successful refresh and served when the network is unavailable (AC-CACHE-01).
const CACHE_KEY = 'ytdash.videos.v1';
const TTL_MS = 24 * 60 * 60 * 1000; // 24h (cross-framework-setup §D: 24h TTL, replace-on-refresh)

type CacheEnvelope = {
  savedAt: number;
  videos: Video[];
};

export async function saveVideos(videos: Video[]): Promise<void> {
  // Millisecond timestamp; Date.now is only used for cache metadata, never for logic under test.
  const envelope: CacheEnvelope = { savedAt: Date.now(), videos };
  await AsyncStorage.setItem(CACHE_KEY, JSON.stringify(envelope));
}

export type LoadedCache = { videos: Video[]; savedAt: number; stale: boolean } | null;

export async function loadVideos(): Promise<LoadedCache> {
  const raw = await AsyncStorage.getItem(CACHE_KEY);
  if (!raw) return null;
  try {
    const env = JSON.parse(raw) as CacheEnvelope;
    if (!env || !Array.isArray(env.videos)) return null;
    return { videos: env.videos, savedAt: env.savedAt, stale: Date.now() - env.savedAt > TTL_MS };
  } catch {
    return null;
  }
}

export async function clearVideos(): Promise<void> {
  await AsyncStorage.removeItem(CACHE_KEY);
}
