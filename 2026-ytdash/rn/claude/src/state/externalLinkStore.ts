import { Linking } from 'react-native';
import { create } from 'zustand';

import { loadTestConfig } from '../data/testConfig';

type ExternalLinkState = {
  capturedUrl: string | null;
  errored: boolean;
  open: (url: string) => Promise<void>;
  clear: () => void;
};

export const useExternalLinkStore = create<ExternalLinkState>((set) => ({
  capturedUrl: null,
  errored: false,

  open: async (url: string) => {
    const testConfig = loadTestConfig();
    if (testConfig.captureExternalLinks) {
      set({ capturedUrl: url, errored: false });
      return;
    }
    try {
      // Linking.canOpenURL unreliably reports false for https on Android even when a
      // handler exists (package-visibility/MATCH_DEFAULT_ONLY quirks) — rely on openURL's
      // own success/failure instead of a canOpenURL pre-check.
      await Linking.openURL(url);
      set({ capturedUrl: null, errored: false });
    } catch {
      set({ capturedUrl: null, errored: true });
    }
  },

  clear: () => set({ capturedUrl: null, errored: false }),
}));
