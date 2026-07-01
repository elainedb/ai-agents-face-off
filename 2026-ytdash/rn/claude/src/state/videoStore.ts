import { create } from 'zustand';
import { AppConfig } from '../appConfig';
import { filterByCategory } from '../domain/filter';
import { Video } from '../domain/models';
import { sortVideos, SortKey } from '../domain/sort';
import { loadVideos } from '../data/repository';

// Explicit, observable view-state (constitution §1.3). The screen renders from `status`.
export type ViewStatus = 'idle' | 'loading' | 'content' | 'empty' | 'error';

type VideoState = {
  status: ViewStatus;
  all: Video[]; // every loaded video (the source of truth for the count)
  errorMessage: string | null;
  stale: boolean; // showing cached data after a network failure
  sortKey: SortKey;
  categoryFilter: string | null;
  load: (cfg: AppConfig) => Promise<void>;
  setSort: (key: SortKey) => void;
  setFilter: (category: string | null) => void;
  // Derived, pure selector: filtered then sorted.
  visible: () => Video[];
};

export const useVideoStore = create<VideoState>((set, get) => ({
  status: 'idle',
  all: [],
  errorMessage: null,
  stale: false,
  sortKey: 'default',
  categoryFilter: null,
  load: async (cfg) => {
    set({ status: 'loading', errorMessage: null });
    const result = await loadVideos(cfg);
    if (result.kind === 'error') {
      set({ status: 'error', errorMessage: result.message, stale: false });
      return;
    }
    set({
      all: result.videos,
      stale: result.kind === 'stale',
      status: result.videos.length ? 'content' : 'empty',
      errorMessage: null,
    });
  },
  setSort: (key) => set({ sortKey: key }),
  setFilter: (category) => set({ categoryFilter: category }),
  visible: () => {
    const { all, categoryFilter, sortKey } = get();
    return sortVideos(filterByCategory(all, categoryFilter), sortKey);
  },
}));
