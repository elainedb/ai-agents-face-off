import { AppConfig } from '../appConfig';
import { Video } from '../domain/models';
import * as cache from './cache';
import { fetchAllVideos } from './youtubeApi';

export type LoadResult =
  | { kind: 'fresh'; videos: Video[] }
  | { kind: 'stale'; videos: Video[] } // network failed, served from cache
  | { kind: 'error'; message: string }; // network failed AND no cache

// Repository = the seam between presentation and data sources (constitution §1.2). Refresh-from-
// network, replace-on-success, stale-cache-fallback-on-failure.
export async function loadVideos(cfg: AppConfig): Promise<LoadResult> {
  try {
    const videos = await fetchAllVideos(cfg);
    await cache.saveVideos(videos);
    return { kind: 'fresh', videos };
  } catch (err) {
    const cached = await cache.loadVideos();
    if (cached && cached.length) {
      return { kind: 'stale', videos: cached };
    }
    return { kind: 'error', message: err instanceof Error ? err.message : 'Failed to load videos' };
  }
}
