import { create } from 'zustand';
import { Video, VideoListStatus, SortDirection, SortKey } from '../domain/types';
import { filterByCategory, sortVideos } from '../domain/filterSort';
import { container } from '../data/container';
import { getTestConfig } from './testConfig';

type VideoState = {
  status: VideoListStatus;
  videos: Video[];
  filterCategory: string | null;
  // null = natural fetch order (no explicit sort chosen yet by the user).
  sortKey: SortKey | null;
  sortDirection: SortDirection;
  errorMessage: string | null;
  isStale: boolean;
  load: () => Promise<void>;
  refresh: () => Promise<void>;
  setFilter: (category: string | null) => void;
  setSort: (key: SortKey, direction: SortDirection) => void;
};

async function fetchAndApply(set: (partial: Partial<VideoState>) => void) {
  set({ status: 'loading', errorMessage: null });
  const cfg = getTestConfig();
  const result = await container.videoRepository.getAll({ baseUrl: cfg.apiBaseUrl, apiKey: cfg.apiKey });
  if (result.kind === 'error') {
    set({ status: 'error', errorMessage: result.message });
    return;
  }
  const videos = result.videos;
  set({
    status: videos.length > 0 ? 'content' : 'empty',
    videos,
    errorMessage: null,
    isStale: result.kind === 'stale',
  });
}

export const useVideoStore = create<VideoState>((set) => ({
  status: 'loading',
  videos: [],
  filterCategory: null,
  sortKey: null,
  sortDirection: 'desc',
  errorMessage: null,
  isStale: false,

  load: () => fetchAndApply(set),
  refresh: () => fetchAndApply(set),

  setFilter: (category) => set({ filterCategory: category }),
  setSort: (key, direction) => set({ sortKey: key, sortDirection: direction }),
}));

// NOTE: deliberately NOT exposed as a zustand selector (e.g. `useVideoStore(selectVisibleVideos)`).
// A selector that allocates a new array on every call breaks `useSyncExternalStore`'s snapshot
// stability check and causes an infinite render loop ("Maximum update depth exceeded"). Callers
// should read the primitives individually and derive this with `useMemo` instead — see
// `useVisibleVideos` below.
export function computeVisibleVideos(
  videos: Video[],
  filterCategory: string | null,
  sortKey: SortKey | null,
  sortDirection: SortDirection,
): Video[] {
  const filtered = filterByCategory(videos, filterCategory);
  if (!sortKey) return filtered;
  return sortVideos(filtered, sortKey, sortDirection);
}
