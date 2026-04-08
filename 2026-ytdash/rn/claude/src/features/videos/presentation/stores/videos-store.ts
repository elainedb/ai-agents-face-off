import { create } from 'zustand';
import type { Video } from '../../domain/entities/video';
import { getContainer } from '@/src/core/di/container';

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

function extractChannels(videos: Video[]): string[] {
  return [...new Set(videos.map((v) => v.channelName))].sort();
}

function extractCountries(videos: Video[]): string[] {
  return [...new Set(videos.map((v) => v.country).filter((c): c is string => c != null))].sort();
}

export const useVideosStore = create<VideosState>((set, get) => ({
  status: 'initial',
  allVideos: [],
  filteredVideos: [],
  filters: { channelName: null, country: null },
  sortOptions: { sortBy: 'publishedDate', sortOrder: 'descending' },
  isRefreshing: false,
  errorMessage: null,
  availableChannels: [],
  availableCountries: [],

  loadVideos: async () => {
    set({ status: 'loading', errorMessage: null });
    const { getVideos } = getContainer();
    const result = await getVideos.execute({ channelIds: CHANNEL_IDS, forceRefresh: false });

    if (result.ok) {
      const { filters, sortOptions } = get();
      set({
        status: 'loaded',
        allVideos: result.data,
        filteredVideos: applyFiltersAndSort(result.data, filters, sortOptions),
        availableChannels: extractChannels(result.data),
        availableCountries: extractCountries(result.data),
        errorMessage: null,
      });
    } else {
      set({ status: 'error', errorMessage: result.error.message });
    }
  },

  refreshVideos: async () => {
    set({ isRefreshing: true, errorMessage: null });
    const { getVideos } = getContainer();
    const result = await getVideos.execute({ channelIds: CHANNEL_IDS, forceRefresh: true });

    if (result.ok) {
      const { filters, sortOptions } = get();
      set({
        status: 'loaded',
        allVideos: result.data,
        filteredVideos: applyFiltersAndSort(result.data, filters, sortOptions),
        availableChannels: extractChannels(result.data),
        availableCountries: extractCountries(result.data),
        isRefreshing: false,
        errorMessage: null,
      });
    } else {
      set({ isRefreshing: false, errorMessage: result.error.message });
    }
  },

  filterByChannel: (channelName) => {
    const { allVideos, filters, sortOptions } = get();
    const newFilters = { ...filters, channelName };
    set({
      filters: newFilters,
      filteredVideos: applyFiltersAndSort(allVideos, newFilters, sortOptions),
    });
  },

  filterByCountry: (country) => {
    const { allVideos, filters, sortOptions } = get();
    const newFilters = { ...filters, country };
    set({
      filters: newFilters,
      filteredVideos: applyFiltersAndSort(allVideos, newFilters, sortOptions),
    });
  },

  sortVideos: (sortBy, sortOrder) => {
    const { allVideos, filters } = get();
    const newSort = { sortBy, sortOrder };
    set({
      sortOptions: newSort,
      filteredVideos: applyFiltersAndSort(allVideos, filters, newSort),
    });
  },

  clearFilters: () => {
    const { allVideos } = get();
    const defaultFilters = { channelName: null, country: null };
    const defaultSort: SortOptions = { sortBy: 'publishedDate', sortOrder: 'descending' };
    set({
      filters: defaultFilters,
      sortOptions: defaultSort,
      filteredVideos: applyFiltersAndSort(allVideos, defaultFilters, defaultSort),
    });
  },
}));
