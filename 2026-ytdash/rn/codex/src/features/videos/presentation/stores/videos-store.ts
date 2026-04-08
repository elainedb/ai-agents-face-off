import { create } from 'zustand';

import type { Video } from '@/src/features/videos/domain/entities/video';
import type { GetVideos } from '@/src/features/videos/domain/usecases/get-videos';

export const CHANNEL_IDS = [
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

interface VideosStoreDependencies {
  getVideos: GetVideos;
}

const defaultSort: SortOptions = {
  sortBy: 'publishedDate',
  sortOrder: 'descending',
};

const applyFiltersAndSort = (
  allVideos: Video[],
  filters: FilterOptions,
  sortOptions: SortOptions
) => {
  const filtered = allVideos
    .filter((video) => !filters.channelName || video.channelName === filters.channelName)
    .filter((video) => !filters.country || video.country === filters.country)
    .sort((left, right) => {
      const leftDate =
        sortOptions.sortBy === 'recordingDate'
          ? left.recordingDate ?? left.publishedAt
          : left.publishedAt;
      const rightDate =
        sortOptions.sortBy === 'recordingDate'
          ? right.recordingDate ?? right.publishedAt
          : right.publishedAt;

      const comparison = leftDate.getTime() - rightDate.getTime();
      return sortOptions.sortOrder === 'ascending' ? comparison : comparison * -1;
    });

  return filtered;
};

const buildUniqueValues = (videos: Video[], selector: (video: Video) => string | null) =>
  [...new Set(videos.map(selector).filter((value): value is string => Boolean(value)))].sort((a, b) =>
    a.localeCompare(b)
  );

export const createVideosStore = (dependencies: VideosStoreDependencies) =>
  create<VideosState>((set, get) => ({
    status: 'initial',
    allVideos: [],
    filteredVideos: [],
    filters: {
      channelName: null,
      country: null,
    },
    sortOptions: defaultSort,
    isRefreshing: false,
    errorMessage: null,
    availableChannels: [],
    availableCountries: [],
    loadVideos: async () => {
      set({ status: 'loading', errorMessage: null });
      const result = await dependencies.getVideos.execute({
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

      const filteredVideos = applyFiltersAndSort(result.data, get().filters, get().sortOptions);

      set({
        status: 'loaded',
        allVideos: result.data,
        filteredVideos,
        availableChannels: buildUniqueValues(result.data, (video) => video.channelName),
        availableCountries: buildUniqueValues(result.data, (video) => video.country),
      });
    },
    refreshVideos: async () => {
      set({ isRefreshing: true, errorMessage: null });

      const result = await dependencies.getVideos.execute({
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

      set((state) => ({
        status: 'loaded',
        isRefreshing: false,
        allVideos: result.data,
        filteredVideos: applyFiltersAndSort(result.data, state.filters, state.sortOptions),
        availableChannels: buildUniqueValues(result.data, (video) => video.channelName),
        availableCountries: buildUniqueValues(result.data, (video) => video.country),
      }));
    },
    filterByChannel: (channelName) =>
      set((state) => ({
        filters: { ...state.filters, channelName },
        filteredVideos: applyFiltersAndSort(
          state.allVideos,
          { ...state.filters, channelName },
          state.sortOptions
        ),
      })),
    filterByCountry: (country) =>
      set((state) => ({
        filters: { ...state.filters, country },
        filteredVideos: applyFiltersAndSort(
          state.allVideos,
          { ...state.filters, country },
          state.sortOptions
        ),
      })),
    sortVideos: (sortBy, sortOrder) =>
      set((state) => ({
        sortOptions: { sortBy, sortOrder },
        filteredVideos: applyFiltersAndSort(state.allVideos, state.filters, { sortBy, sortOrder }),
      })),
    clearFilters: () =>
      set((state) => ({
        filters: { channelName: null, country: null },
        sortOptions: defaultSort,
        filteredVideos: applyFiltersAndSort(
          state.allVideos,
          { channelName: null, country: null },
          defaultSort
        ),
      })),
  }));
