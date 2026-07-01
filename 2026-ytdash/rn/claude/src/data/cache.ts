import AsyncStorage from '@react-native-async-storage/async-storage';
import { Video } from '../domain/models';

// Local persistence — the single source of truth the UI reads from (constitution §1.5). The
// network refreshes this store; on network failure the UI falls back to the last good snapshot.
const CACHE_KEY = 'ytdash.videos.v1';

type CacheEnvelope = { savedAt: number; videos: Video[] };

export async function saveVideos(videos: Video[]): Promise<void> {
  const envelope: CacheEnvelope = { savedAt: Date.now(), videos };
  try {
    await AsyncStorage.setItem(CACHE_KEY, JSON.stringify(envelope));
  } catch {
    // Persistence failure must not crash the app; the in-memory list still renders.
  }
}

export async function loadVideos(): Promise<Video[] | null> {
  try {
    const raw = await AsyncStorage.getItem(CACHE_KEY);
    if (!raw) return null;
    const parsed = JSON.parse(raw) as CacheEnvelope;
    if (!parsed || !Array.isArray(parsed.videos)) return null;
    return parsed.videos;
  } catch {
    return null;
  }
}

export async function clearVideos(): Promise<void> {
  try {
    await AsyncStorage.removeItem(CACHE_KEY);
  } catch {
    /* ignore */
  }
}
