import { create } from 'zustand';

import { getContainer } from '@/src/core/di/container';
import { Video } from '@/src/features/videos/domain/entities/video';

const CHANNEL_IDS = [
  'UCynoa1DjwnvHAowA_jiMEAQ',
  'UCK0KOjX3beyB9nzonls0cuw',
  'UCACkIrvrGAQ7kuc0hMVwvmA',
  'UCtWRAKKvOEA0CXOue9BG8ZA',
];

export type VideosStatus = 'initial' | 'loading' | 'loaded' | 'error';

export interface SortOptions {
  sortBy: 'publishedDate' | 'recordingDate';
  sortOrder: 'ascending' | 'descending';
}

export interface FilterOptions {
  channelName: string | null;
  country: string | null;
}

interface VideosState {
  status: VideosStatus;
  allVideos: Video[];
  filteredVideos: Video[];
  filters: FilterOptions;
  sortOptions: SortOptions;
  isRefreshing: boolean;
  errorMessage: string | null;
  availableChannels: string[];
  availableCountries: string[];
  loadVideos: () => Promise<void>;
  refreshVideos: () => Promise<void>;
  filterByChannel: (channelName: string | null) => void;
  filterByCountry: (country: string | null) => void;
  sortVideos: (sortBy: SortOptions['sortBy'], sortOrder: SortOptions['sortOrder']) => void;
  clearFilters: () => void;
}

const defaultFilters: FilterOptions = {
  channelName: null,
  country: null,
};

const defaultSort: SortOptions = {
  sortBy: 'publishedDate',
  sortOrder: 'descending',
};

const applyFiltersAndSort = (
  videos: Video[],
  filters: FilterOptions,
  sortOptions: SortOptions,
): Video[] => {
  const filtered = videos
    .filter((video) => (filters.channelName ? video.channelName === filters.channelName : true))
    .filter((video) => (filters.country ? video.country === filters.country : true));

  const factor = sortOptions.sortOrder === 'ascending' ? 1 : -1;

  return [...filtered].sort((left, right) => {
    const leftTime =
      sortOptions.sortBy === 'recordingDate'
        ? (left.recordingDate ?? left.publishedAt).getTime()
        : left.publishedAt.getTime();
    const rightTime =
      sortOptions.sortBy === 'recordingDate'
        ? (right.recordingDate ?? right.publishedAt).getTime()
        : right.publishedAt.getTime();

    return (leftTime - rightTime) * factor;
  });
};

const getCollections = (videos: Video[]) => ({
  availableChannels: [...new Set(videos.map((video) => video.channelName))].sort((a, b) =>
    a.localeCompare(b),
  ),
  availableCountries: [
    ...new Set(
      videos
        .map((video) => video.country)
        .filter((country): country is string => typeof country === 'string' && country.length > 0),
    ),
  ].sort((a, b) => a.localeCompare(b)),
});

export const useVideosStore = create<VideosState>((set, get) => ({
  status: 'initial',
  allVideos: [],
  filteredVideos: [],
  filters: defaultFilters,
  sortOptions: defaultSort,
  isRefreshing: false,
  errorMessage: null,
  availableChannels: [],
  availableCountries: [],
  loadVideos: async () => {
    set((state) => ({
      ...state,
      status: 'loading',
      errorMessage: null,
    }));

    const result = await getContainer().getVideos.execute({
      channelIds: CHANNEL_IDS,
      forceRefresh: false,
    });

    if (!result.ok) {
      set({
        status: 'error',
        allVideos: [],
        filteredVideos: [],
        filters: defaultFilters,
        sortOptions: defaultSort,
        isRefreshing: false,
        errorMessage: result.error.message,
        availableChannels: [],
        availableCountries: [],
      });
      return;
    }

    const collections = getCollections(result.data);
    set((state) => ({
      ...state,
      status: 'loaded',
      allVideos: result.data,
      filteredVideos: applyFiltersAndSort(result.data, state.filters, state.sortOptions),
      errorMessage: null,
      availableChannels: collections.availableChannels,
      availableCountries: collections.availableCountries,
    }));
  },
  refreshVideos: async () => {
    set((state) => ({
      ...state,
      isRefreshing: true,
      errorMessage: null,
    }));

    const result = await getContainer().getVideos.execute({
      channelIds: CHANNEL_IDS,
      forceRefresh: true,
    });

    if (!result.ok) {
      set((state) => ({
        ...state,
        status: state.allVideos.length > 0 ? 'loaded' : 'error',
        isRefreshing: false,
        errorMessage: result.error.message,
      }));
      return;
    }

    const { filters, sortOptions } = get();
    const collections = getCollections(result.data);
    set((state) => ({
      ...state,
      status: 'loaded',
      allVideos: result.data,
      filteredVideos: applyFiltersAndSort(result.data, filters, sortOptions),
      isRefreshing: false,
      errorMessage: null,
      availableChannels: collections.availableChannels,
      availableCountries: collections.availableCountries,
    }));
  },
  filterByChannel: (channelName) => {
    const state = get();
    const filters = { ...state.filters, channelName };
    set({
      filters,
      filteredVideos: applyFiltersAndSort(state.allVideos, filters, state.sortOptions),
    });
  },
  filterByCountry: (country) => {
    const state = get();
    const filters = { ...state.filters, country };
    set({
      filters,
      filteredVideos: applyFiltersAndSort(state.allVideos, filters, state.sortOptions),
    });
  },
  sortVideos: (sortBy, sortOrder) => {
    const state = get();
    const sortOptions = { sortBy, sortOrder };
    set({
      sortOptions,
      filteredVideos: applyFiltersAndSort(state.allVideos, state.filters, sortOptions),
    });
  },
  clearFilters: () => {
    const state = get();
    set({
      filters: defaultFilters,
      sortOptions: defaultSort,
      filteredVideos: applyFiltersAndSort(state.allVideos, defaultFilters, defaultSort),
    });
  },
}));
