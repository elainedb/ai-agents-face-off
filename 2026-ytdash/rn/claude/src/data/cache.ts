import AsyncStorage from '@react-native-async-storage/async-storage';
import { Video, Result, ok, err } from './types';

const KEY = 'ytdash.videos.v1';
const TTL_MS = 24 * 60 * 60 * 1000; // 24h

type Snapshot = { savedAt: number; videos: Video[] };

/** Persist the last good list so the UI has a single on-disk source of truth (constitution §1.5). */
export async function saveVideos(videos: Video[]): Promise<Result<void>> {
  try {
    const snap: Snapshot = { savedAt: Date.now(), videos };
    await AsyncStorage.setItem(KEY, JSON.stringify(snap));
    return ok(undefined);
  } catch (e) {
    return err('persistence', e instanceof Error ? e.message : String(e));
  }
}

export type LoadedCache = { videos: Video[]; fresh: boolean } | null;

/** Load the cached list. `fresh` = within TTL. Callers serve stale on network failure. */
export async function loadVideos(): Promise<LoadedCache> {
  try {
    const raw = await AsyncStorage.getItem(KEY);
    if (!raw) return null;
    const snap = JSON.parse(raw) as Snapshot;
    if (!snap || !Array.isArray(snap.videos)) return null;
    return { videos: snap.videos, fresh: Date.now() - snap.savedAt < TTL_MS };
  } catch {
    return null;
  }
}

export async function clearVideos(): Promise<void> {
  try {
    await AsyncStorage.removeItem(KEY);
  } catch {
    // ignore
  }
}
