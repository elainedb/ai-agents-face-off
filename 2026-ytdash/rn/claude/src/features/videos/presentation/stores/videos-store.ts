import { create } from 'zustand';
import { Video } from '../../domain/entities/video';
import { getContainer } from '../../../../core/di/container';

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
  allVideos: Video[],
  filters: FilterOptions,
  sortOptions: SortOptions,
): Video[] {
  let result = [...allVideos];

  if (filters.channelName) {
    result = result.filter((v) => v.channelName === filters.channelName);
  }
  if (filters.country) {
    result = result.filter((v) => v.country === filters.country);
  }

  result.sort((a, b) => {
    let aTime: number;
    let bTime: number;

    if (sortOptions.sortBy === 'recordingDate') {
      aTime = (a.recordingDate ?? a.publishedAt).getTime();
      bTime = (b.recordingDate ?? b.publishedAt).getTime();
    } else {
      aTime = a.publishedAt.getTime();
      bTime = b.publishedAt.getTime();
    }

    return sortOptions.sortOrder === 'descending' ? bTime - aTime : aTime - bTime;
  });

  return result;
}

function getUniqueChannels(videos: Video[]): string[] {
  return [...new Set(videos.map((v) => v.channelName))].sort();
}

function getUniqueCountries(videos: Video[]): string[] {
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
    try {
      const container = getContainer();
      const result = await container.getVideos.execute({
        channelIds: CHANNEL_IDS,
        forceRefresh: false,
      });
      if (result.ok) {
        const { filters, sortOptions } = get();
        set({
          status: 'loaded',
          allVideos: result.data,
          filteredVideos: applyFiltersAndSort(result.data, filters, sortOptions),
          availableChannels: getUniqueChannels(result.data),
          availableCountries: getUniqueCountries(result.data),
          errorMessage: null,
        });
      } else {
        set({ status: 'error', errorMessage: result.error.message });
      }
    } catch {
      set({ status: 'error', errorMessage: 'An unexpected error occurred' });
    }
  },

  refreshVideos: async () => {
    set({ isRefreshing: true });
    try {
      const container = getContainer();
      const result = await container.getVideos.execute({
        channelIds: CHANNEL_IDS,
        forceRefresh: true,
      });
      if (result.ok) {
        const { filters, sortOptions } = get();
        set({
          status: 'loaded',
          allVideos: result.data,
          filteredVideos: applyFiltersAndSort(result.data, filters, sortOptions),
          availableChannels: getUniqueChannels(result.data),
          availableCountries: getUniqueCountries(result.data),
          isRefreshing: false,
          errorMessage: null,
        });
      } else {
        set({ isRefreshing: false, errorMessage: result.error.message });
      }
    } catch {
      set({ isRefreshing: false, errorMessage: 'An unexpected error occurred' });
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
    const defaultFilters: FilterOptions = { channelName: null, country: null };
    const defaultSort: SortOptions = { sortBy: 'publishedDate', sortOrder: 'descending' };
    set({
      filters: defaultFilters,
      sortOptions: defaultSort,
      filteredVideos: applyFiltersAndSort(allVideos, defaultFilters, defaultSort),
    });
  },
}));
