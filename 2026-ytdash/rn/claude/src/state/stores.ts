import { create } from 'zustand';
import { Linking } from 'react-native';
import { Video, UiStatus, AppError } from '../data/types';
import { fetchAllVideos } from '../data/api';
import { loadVideos, saveVideos } from '../data/cache';
import { isAuthorized } from '../domain/auth';
import { SortOption } from '../domain/sort';
import { getAppConfig } from './appConfig';

// ---------------- Auth ----------------
type AuthState = {
  email: string | null;
  error: string | null;
  signIn: (email: string | null | undefined) => boolean;
  signOut: () => void;
};

export const useAuthStore = create<AuthState>((set) => ({
  email: null,
  error: null,
  signIn: (email) => {
    const { whitelist } = getAppConfig();
    if (isAuthorized(email, whitelist)) {
      set({ email: (email as string).trim().toLowerCase(), error: null });
      return true;
    }
    set({ email: null, error: 'This account is not authorized to use this app.' });
    return false;
  },
  signOut: () => set({ email: null, error: null }),
}));

// ---------------- Videos ----------------
type VideosState = {
  status: UiStatus;
  all: Video[];
  error: AppError | null;
  load: () => Promise<void>;
  refresh: () => Promise<void>;
  reset: () => void;
};

export const useVideosStore = create<VideosState>((set, get) => ({
  status: 'idle',
  all: [],
  error: null,

  load: async () => {
    // 1. Hydrate from the on-disk source of truth first so the UI has content immediately.
    const cached = await loadVideos();
    if (cached && cached.videos.length > 0) {
      set({ all: cached.videos, status: 'content', error: null });
    } else {
      set({ status: 'loading', error: null });
    }
    // 2. Refresh from the network.
    const result = await fetchAllVideos(getAppConfig().api);
    if (result.ok) {
      await saveVideos(result.value);
      set({
        all: result.value,
        status: result.value.length > 0 ? 'content' : 'empty',
        error: null,
      });
    } else if (get().all.length > 0) {
      // Stale-fallback: keep cached content, surface NO blocking error (AC-CACHE-01).
      set({ status: 'content', error: null });
    } else {
      set({ status: 'error', error: result.error });
    }
  },

  refresh: async () => {
    const result = await fetchAllVideos(getAppConfig().api);
    if (result.ok) {
      await saveVideos(result.value);
      set({
        all: result.value,
        status: result.value.length > 0 ? 'content' : 'empty',
        error: null,
      });
    } else if (get().all.length > 0) {
      set({ status: 'content', error: null });
    } else {
      set({ status: 'error', error: result.error });
    }
  },

  reset: () => set({ status: 'idle', all: [], error: null }),
}));

// ---------------- UI (navigation + filter/sort) ----------------
export type Screen = 'login' | 'home' | 'map';

type UiState = {
  screen: Screen;
  filter: string | null; // category label; null = all
  sort: SortOption | null; // null = fetch order (default)
  setScreen: (s: Screen) => void;
  setFilter: (c: string | null) => void;
  setSort: (o: SortOption | null) => void;
};

export const useUiStore = create<UiState>((set) => ({
  screen: 'login',
  filter: null,
  sort: null,
  setScreen: (screen) => set({ screen }),
  setFilter: (filter) => set({ filter }),
  setSort: (sort) => set({ sort }),
}));

// ---------------- External open (app-root banner) ----------------
type ExternalState = {
  capturedUrl: string | null;
  openError: string | null;
  open: (url: string) => Promise<void>;
  clear: () => void;
};

export const useExternalStore = create<ExternalState>((set) => ({
  capturedUrl: null,
  openError: null,
  open: async (url) => {
    const { captureExternalLinks } = getAppConfig();
    if (captureExternalLinks) {
      // Deterministic capture: surface the exact URL instead of launching (constitution §4).
      set({ capturedUrl: url, openError: null });
      return;
    }
    // Real launch. Do NOT gate on canOpenURL (its false-negatives are the AC-LINK-01 trap);
    // just open and surface a visible error if it throws (constitution §1.6 / §4).
    try {
      await Linking.openURL(url);
      set({ capturedUrl: null, openError: null });
    } catch (e) {
      set({ openError: e instanceof Error ? e.message : 'Could not open link', capturedUrl: null });
    }
  },
  clear: () => set({ capturedUrl: null, openError: null }),
}));
