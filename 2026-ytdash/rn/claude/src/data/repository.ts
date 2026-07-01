import { AppConfig, Video } from '../domain/types';
import { loadVideos, saveVideos } from './cache';
import { fetchAllVideos } from './youtubeApi';

export type RepoResult = {
  videos: Video[];
  fromCache: boolean; // true when served from the local store after a network failure
};

// VideoRepository — single seam between UI and (network + cache). Network refreshes the store;
// the store is the fallback. This is what makes offline/cache behavior testable (constitution §1.5).
export class VideoRepository {
  async getVideos(cfg: AppConfig): Promise<RepoResult> {
    try {
      const fresh = await fetchAllVideos(cfg);
      // Replace-on-refresh: persist the latest good list.
      await saveVideos(fresh);
      return { videos: fresh, fromCache: false };
    } catch (networkErr) {
      // Stale-fallback: if the network fails but we have a cached list, serve it (no error state).
      const cached = await loadVideos();
      if (cached && cached.videos.length > 0) {
        return { videos: cached.videos, fromCache: true };
      }
      // No cache to fall back to → surface the error to the UI (with retry).
      throw networkErr;
    }
  }

  // Cache-first read (used at startup so a fresh process shows something immediately if offline).
  async getCachedVideos(): Promise<Video[]> {
    const cached = await loadVideos();
    return cached?.videos ?? [];
  }
}

export const videoRepository = new VideoRepository();
