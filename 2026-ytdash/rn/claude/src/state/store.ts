import { Linking } from 'react-native';
import { create } from 'zustand';

import { AuthService } from '../data/auth/AuthService';
import { GoogleAuthService } from '../data/auth/GoogleAuthService';
import { MockAuthService } from '../data/auth/MockAuthService';
import { videoRepository } from '../data/repository';
import { isAuthorized } from '../domain/auth';
import { ALL_FILTER, AppConfig, SortKey, UiStatus, Video } from '../domain/types';

export type Screen = 'login' | 'home' | 'map';

type State = {
  config: AppConfig | null;

  screen: Screen;

  // Auth view-state
  user: { email: string } | null;
  signingIn: boolean;
  authError: string | null;

  // Videos view-state (constitution §1.3 — explicit observable status)
  videos: Video[];
  status: UiStatus;
  error: string | null;
  refreshing: boolean;
  fromCache: boolean;

  // Sort / filter
  sortKey: SortKey | null; // null = fetch order (default)
  filterLabel: string;

  // Map detail sheet
  selectedVideo: Video | null;

  // External-open seam (lifted to the root so both the list and the map sheet share it)
  externalUrl: string | null;
  externalError: string | null;

  // Actions
  init: (config: AppConfig) => void;
  signIn: () => Promise<void>;
  signOut: () => Promise<void>;
  loadVideos: () => Promise<void>;
  refresh: () => Promise<void>;
  setSort: (key: SortKey) => void;
  setFilter: (label: string) => void;
  navigate: (screen: Screen) => void;
  selectVideo: (video: Video) => void;
  closeSheet: () => void;
  openExternal: (url: string) => Promise<void>;
  dismissExternal: () => void;
};

function authServiceFor(config: AppConfig): AuthService {
  return config.uiTestMode
    ? new MockAuthService(config.mockAuthEmail)
    : new GoogleAuthService();
}

export const useStore = create<State>((set, get) => ({
  config: null,
  screen: 'login',
  user: null,
  signingIn: false,
  authError: null,
  videos: [],
  status: 'idle',
  error: null,
  refreshing: false,
  fromCache: false,
  sortKey: null,
  filterLabel: ALL_FILTER,
  selectedVideo: null,
  externalUrl: null,
  externalError: null,

  init: (config) => set({ config }),

  signIn: async () => {
    const config = get().config;
    if (!config) return;
    set({ signingIn: true, authError: null });
    try {
      const service = authServiceFor(config);
      const user = await service.signIn();
      if (!isAuthorized(user.email, config.authorizedEmails)) {
        // Non-authorized email: denied, stays out of the app (AC-LOGIN-02).
        set({ signingIn: false, authError: 'This account is not authorized to use ytdash.' });
        return;
      }
      set({ user, signingIn: false, authError: null, screen: 'home' });
      await get().loadVideos();
    } catch (e) {
      set({ signingIn: false, authError: errorMessage(e) });
    }
  },

  signOut: async () => {
    const config = get().config;
    if (config) {
      try {
        await authServiceFor(config).signOut();
      } catch {
        // Sign-out failure must not trap the user; fall through to the login screen.
      }
    }
    set({
      user: null,
      screen: 'login',
      selectedVideo: null,
      externalUrl: null,
      externalError: null,
    });
  },

  loadVideos: async () => {
    const config = get().config;
    if (!config) return;
    set({ status: 'loading', error: null });
    try {
      const result = await videoRepository.getVideos(config);
      set({
        videos: result.videos,
        fromCache: result.fromCache,
        status: result.videos.length === 0 ? 'empty' : 'content',
        error: null,
      });
    } catch (e) {
      // Last resort: try whatever is cached before showing a blocking error.
      const cached = await videoRepository.getCachedVideos();
      if (cached.length > 0) {
        set({ videos: cached, fromCache: true, status: 'content', error: null });
      } else {
        set({ status: 'error', error: errorMessage(e) });
      }
    }
  },

  refresh: async () => {
    const config = get().config;
    if (!config) return;
    set({ refreshing: true });
    try {
      const result = await videoRepository.getVideos(config);
      set({
        videos: result.videos,
        fromCache: result.fromCache,
        status: result.videos.length === 0 ? 'empty' : 'content',
        error: null,
        refreshing: false,
      });
    } catch (e) {
      // Refresh failure keeps the existing list on screen (no blocking error if we have data).
      const hasData = get().videos.length > 0;
      set({ refreshing: false, error: hasData ? null : errorMessage(e), status: hasData ? 'content' : 'error' });
    }
  },

  setSort: (key) => set({ sortKey: key }),
  setFilter: (label) => set({ filterLabel: label }),
  navigate: (screen) => set({ screen }),
  selectVideo: (video) => set({ selectedVideo: video }),
  closeSheet: () => set({ selectedVideo: null }),

  openExternal: async (url) => {
    const config = get().config;
    // UI-test-mode capture: surface the target URL instead of launching (constitution §4).
    if (config?.captureExternalLinks) {
      set({ externalUrl: url, externalError: null });
      return;
    }
    // Real external launch. Call openURL directly (do NOT gate on canOpenURL — that is the classic
    // RN deep-link footgun). Any failure surfaces external_open_error rather than crashing (§6).
    try {
      await Linking.openURL(url);
      set({ externalError: null });
    } catch (e) {
      set({ externalError: errorMessage(e) });
    }
  },

  dismissExternal: () => set({ externalUrl: null, externalError: null }),
}));

function errorMessage(e: unknown): string {
  return e instanceof Error ? e.message : String(e);
}
