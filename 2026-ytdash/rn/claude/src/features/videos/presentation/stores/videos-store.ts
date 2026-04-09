import { create } from 'zustand';
import { Video } from '../../domain/entities/video';
import { container } from '@/src/core/di/container';

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

export interface VideosState {
  status: VideosStatus;
  allVideos: Video[];
  filteredVideos: Video[];
  filters: FilterOptions;
  sortOptions: SortOptions;
  isRefreshing: boolean;
  errorMessage: string | null;
  loadVideos: () => Promise<void>;
  refreshVideos: () => Promise<void>;
  filterByChannel: (channelName: string | null) => void;
  filterByCountry: (country: string | null) => void;
  sortVideos: (sortBy: SortOptions['sortBy'], sortOrder: SortOptions['sortOrder']) => void;
  clearFilters: () => void;
}

function applyFiltersAndSort(
  videos: Video[],
  filters: FilterOptions,
  sortOptions: SortOptions,
): Video[] {
  let result = [...videos];

  if (filters.channelName) {
    result = result.filter((v) => v.channelName === filters.channelName);
  }
  if (filters.country) {
    result = result.filter((v) => v.country === filters.country);
  }

  result.sort((a, b) => {
    let dateA: number;
    let dateB: number;

    if (sortOptions.sortBy === 'recordingDate') {
      dateA = (a.recordingDate ?? a.publishedAt).getTime();
      dateB = (b.recordingDate ?? b.publishedAt).getTime();
    } else {
      dateA = a.publishedAt.getTime();
      dateB = b.publishedAt.getTime();
    }

    return sortOptions.sortOrder === 'descending' ? dateB - dateA : dateA - dateB;
  });

  return result;
}

export const useVideosStore = create<VideosState>((set, get) => ({
  status: 'initial',
  allVideos: [],
  filteredVideos: [],
  filters: { channelName: null, country: null },
  sortOptions: { sortBy: 'publishedDate', sortOrder: 'descending' },
  isRefreshing: false,
  errorMessage: null,

  loadVideos: async () => {
    set({ status: 'loading', errorMessage: null });
    const result = await container.getVideos.execute({
      channelIds: CHANNEL_IDS,
      forceRefresh: false,
    });
    if (result.ok) {
      const { filters, sortOptions } = get();
      const filtered = applyFiltersAndSort(result.data, filters, sortOptions);
      set({ status: 'loaded', allVideos: result.data, filteredVideos: filtered });
    } else {
      set({ status: 'error', errorMessage: result.error.message });
    }
  },

  refreshVideos: async () => {
    set({ isRefreshing: true });
    const result = await container.getVideos.execute({
      channelIds: CHANNEL_IDS,
      forceRefresh: true,
    });
    if (result.ok) {
      const { filters, sortOptions } = get();
      const filtered = applyFiltersAndSort(result.data, filters, sortOptions);
      set({
        status: 'loaded',
        allVideos: result.data,
        filteredVideos: filtered,
        isRefreshing: false,
        errorMessage: null,
      });
    } else {
      set({ isRefreshing: false, errorMessage: result.error.message });
    }
  },

  filterByChannel: (channelName) => {
    const { allVideos, sortOptions, filters } = get();
    const newFilters = { ...filters, channelName };
    const filtered = applyFiltersAndSort(allVideos, newFilters, sortOptions);
    set({ filters: newFilters, filteredVideos: filtered });
  },

  filterByCountry: (country) => {
    const { allVideos, sortOptions, filters } = get();
    const newFilters = { ...filters, country };
    const filtered = applyFiltersAndSort(allVideos, newFilters, sortOptions);
    set({ filters: newFilters, filteredVideos: filtered });
  },

  sortVideos: (sortBy, sortOrder) => {
    const { allVideos, filters } = get();
    const newSort = { sortBy, sortOrder };
    const filtered = applyFiltersAndSort(allVideos, filters, newSort);
    set({ sortOptions: newSort, filteredVideos: filtered });
  },

  clearFilters: () => {
    const { allVideos } = get();
    const defaultFilters: FilterOptions = { channelName: null, country: null };
    const defaultSort: SortOptions = { sortBy: 'publishedDate', sortOrder: 'descending' };
    const filtered = applyFiltersAndSort(allVideos, defaultFilters, defaultSort);
    set({ filters: defaultFilters, sortOptions: defaultSort, filteredVideos: filtered });
  },

}));
