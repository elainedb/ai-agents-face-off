import { create } from 'zustand';

import { loadCached, refresh as refreshFromNetwork } from '../data/videoRepository';
import { SortDirection, UiStatus, Video } from '../domain/types';
import { useTestConfigStore } from './testConfigStore';

type VideoState = {
  status: UiStatus;
  videos: Video[];
  filter: string | null;
  sortDirection: SortDirection | null;
  errorMessage: string | null;
  refresh: () => Promise<void>;
  setFilter: (category: string | null) => void;
  setSortDirection: (direction: SortDirection | null) => void;
};

export const useVideoStore = create<VideoState>((set, get) => ({
  status: 'loading',
  videos: [],
  filter: null,
  sortDirection: null,
  errorMessage: null,

  refresh: async () => {
    if (get().videos.length === 0) set({ status: 'loading' });
    const cfg = useTestConfigStore.getState();

    const result = await refreshFromNetwork(cfg.apiBaseUrl, cfg.apiKey);
    if (result.ok) {
      set({
        status: result.value.length > 0 ? 'content' : 'empty',
        videos: result.value,
        errorMessage: null,
      });
      return;
    }

    // Network refresh failed — fall back to the persisted cache (constitution §1.5, AC-CACHE-01)
    // rather than blocking on an error state, as long as SOME cached data exists.
    const cached = await loadCached();
    if (cached && cached.length > 0) {
      set({ status: 'content', videos: cached, errorMessage: null });
    } else {
      set({ status: 'error', errorMessage: result.error.message });
    }
  },

  setFilter: (category) => set({ filter: category }),
  setSortDirection: (direction) => set({ sortDirection: direction }),
}));
