import { create } from 'zustand';

import { initVideosContainer } from '@/src/core/di/container';
import type { Video } from '@/src/features/videos/domain/entities/video';

export const CHANNEL_IDS = [
  'UCynoa1DjwnvHAowA_jiMEAQ',
  'UCK0KOjX3beyB9nzonls0cuw',
  'UCACkIrvrGAQ7kuc0hMVwvmA',
  'UCtWRAKKvOEA0CXOue9BG8ZA',
];

export type VideosStatus = 'initial' | 'loading' | 'loaded' | 'error';
export type SortField = 'publishedAt' | 'recordingDate';
export type SortOrder = 'desc' | 'asc';

export interface FilterOptions {
  channelName: string | null;
  country: string | null;
}

export interface SortOptions {
  sortBy: SortField;
  sortOrder: SortOrder;
}

interface VideosState {
  status: VideosStatus;
  allVideos: Video[];
  filteredVideos: Video[];
  filters: FilterOptions;
  sortOptions: SortOptions;
  availableChannels: string[];
  availableCountries: string[];
  isRefreshing: boolean;
  errorMessage: string | null;
  loadVideos: () => Promise<void>;
  refreshVideos: () => Promise<void>;
  filterByChannel: (channelName: string | null) => void;
  filterByCountry: (country: string | null) => void;
  sortVideos: (sortBy: SortField, sortOrder: SortOrder) => void;
  clearFilters: () => void;
}

const defaultSort: SortOptions = {
  sortBy: 'publishedAt',
  sortOrder: 'desc',
};

const sortVideosList = (videos: Video[], sortOptions: SortOptions): Video[] => {
  const sorted = [...videos];
  sorted.sort((left, right) => {
    const leftDate =
      sortOptions.sortBy === 'recordingDate'
        ? left.recordingDate?.getTime() ?? left.publishedAt.getTime()
        : left.publishedAt.getTime();
    const rightDate =
      sortOptions.sortBy === 'recordingDate'
        ? right.recordingDate?.getTime() ?? right.publishedAt.getTime()
        : right.publishedAt.getTime();

    return sortOptions.sortOrder === 'desc' ? rightDate - leftDate : leftDate - rightDate;
  });
  return sorted;
};

const deriveOptions = (videos: Video[]) => ({
  availableChannels: [...new Set(videos.map((video) => video.channelName))].sort(),
  availableCountries: [...new Set(videos.map((video) => video.country).filter(Boolean) as string[])].sort(),
});

const applyFiltersAndSort = (
  allVideos: Video[],
  filters: FilterOptions,
  sortOptions: SortOptions
): Video[] => {
  const filtered = allVideos.filter((video) => {
    const channelMatches = !filters.channelName || video.channelName === filters.channelName;
    const countryMatches = !filters.country || video.country === filters.country;
    return channelMatches && countryMatches;
  });

  return sortVideosList(filtered, sortOptions);
};

export const useVideosStore = create<VideosState>((set, get) => ({
  status: 'initial',
  allVideos: [],
  filteredVideos: [],
  filters: { channelName: null, country: null },
  sortOptions: defaultSort,
  availableChannels: [],
  availableCountries: [],
  isRefreshing: false,
  errorMessage: null,
  async loadVideos() {
    set({ status: 'loading', errorMessage: null });
    const container = await initVideosContainer();
    const result = await container.getVideos.execute({
      channelIds: CHANNEL_IDS,
      forceRefresh: false,
    });

    if (!result.ok) {
      set({
        status: 'error',
        errorMessage: result.error.message,
      });
      return;
    }

    const state = get();
    const derived = deriveOptions(result.data);
    set({
      status: 'loaded',
      allVideos: result.data,
      filteredVideos: applyFiltersAndSort(result.data, state.filters, state.sortOptions),
      availableChannels: derived.availableChannels,
      availableCountries: derived.availableCountries,
      errorMessage: null,
    });
  },
  async refreshVideos() {
    set({ isRefreshing: true, errorMessage: null });
    const container = await initVideosContainer();
    const result = await container.getVideos.execute({
      channelIds: CHANNEL_IDS,
      forceRefresh: true,
    });

    if (!result.ok) {
      set({
        isRefreshing: false,
        status: 'error',
        errorMessage: result.error.message,
      });
      return;
    }

    const state = get();
    const derived = deriveOptions(result.data);
    set({
      status: 'loaded',
      isRefreshing: false,
      allVideos: result.data,
      filteredVideos: applyFiltersAndSort(result.data, state.filters, state.sortOptions),
      availableChannels: derived.availableChannels,
      availableCountries: derived.availableCountries,
      errorMessage: null,
    });
  },
  filterByChannel(channelName) {
    const state = get();
    const filters = { ...state.filters, channelName };
    set({
      filters,
      filteredVideos: applyFiltersAndSort(state.allVideos, filters, state.sortOptions),
    });
  },
  filterByCountry(country) {
    const state = get();
    const filters = { ...state.filters, country };
    set({
      filters,
      filteredVideos: applyFiltersAndSort(state.allVideos, filters, state.sortOptions),
    });
  },
  sortVideos(sortBy, sortOrder) {
    const state = get();
    const sortOptions = { sortBy, sortOrder };
    set({
      sortOptions,
      filteredVideos: applyFiltersAndSort(state.allVideos, state.filters, sortOptions),
    });
  },
  clearFilters() {
    const state = get();
    set({
      filters: { channelName: null, country: null },
      sortOptions: defaultSort,
      filteredVideos: applyFiltersAndSort(state.allVideos, { channelName: null, country: null }, defaultSort),
    });
  },
}));
