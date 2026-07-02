import { create } from 'zustand';
import Constants from 'expo-constants';

import type { SortKey, Video, ViewState } from '../domain/models';
import { filterVideos, sortVideos } from '../domain/sortFilter';
import { readCache, writeCache } from '../data/cache';
import { loadSourceChannels } from '../data/channels';
import { loadTestConfig } from '../data/testConfig';
import { fetchAllVideos } from '../data/youtubeApi';

type VideoState = {
  allVideos: Video[];
  viewState: ViewState;
  filterLabel: string | null;
  sortKey: SortKey;
  selectedVideoId: string | null;
  visibleVideos: () => Video[];
  load: () => Promise<void>;
  refresh: () => Promise<void>;
  setFilter: (label: string | null) => void;
  setSort: (key: SortKey) => void;
  selectMarker: (id: string | null) => void;
  reset: () => void;
};

function apiConfig() {
  const testConfig = loadTestConfig();
  const extra = Constants.expoConfig?.extra as Record<string, string> | undefined;
  const baseUrl = testConfig.apiBaseUrl || extra?.apiBaseUrl || 'https://www.googleapis.com';
  const apiKey = testConfig.apiKey || extra?.youtubeApiKey || '';
  return { baseUrl, apiKey };
}

async function fetchFresh(): Promise<Video[]> {
  const { baseUrl, apiKey } = apiConfig();
  const channels = loadSourceChannels();
  return fetchAllVideos(channels, baseUrl, apiKey);
}

export const useVideoStore = create<VideoState>((set, get) => ({
  allVideos: [],
  viewState: 'loading',
  filterLabel: null,
  sortKey: 'none',
  selectedVideoId: null,

  visibleVideos: () => {
    const { allVideos, filterLabel, sortKey } = get();
    return sortVideos(filterVideos(allVideos, filterLabel), sortKey);
  },

  load: async () => {
    set({ viewState: 'loading' });
    const cached = await readCache();
    if (cached && cached.length > 0) {
      set({ allVideos: cached, viewState: 'content' });
    }
    try {
      const fresh = await fetchFresh();
      await writeCache(fresh);
      set({ allVideos: fresh, viewState: fresh.length > 0 ? 'content' : 'empty' });
    } catch (err) {
      if (cached && cached.length > 0) {
        // stale-fallback: keep showing what we have, no blocking error
        set({ allVideos: cached, viewState: 'content' });
      } else {
        set({ viewState: 'error' });
      }
    }
  },

  refresh: async () => {
    const { allVideos } = get();
    try {
      const fresh = await fetchFresh();
      await writeCache(fresh);
      set({ allVideos: fresh, viewState: fresh.length > 0 ? 'content' : 'empty' });
    } catch (err) {
      if (allVideos.length > 0) {
        set({ viewState: 'content' });
      } else {
        set({ viewState: 'error' });
      }
    }
  },

  setFilter: (label) => set({ filterLabel: label }),
  setSort: (key) => set({ sortKey: key }),
  selectMarker: (id) => set({ selectedVideoId: id }),
  reset: () => set({ allVideos: [], viewState: 'loading', filterLabel: null, sortKey: 'none', selectedVideoId: null }),
}));
