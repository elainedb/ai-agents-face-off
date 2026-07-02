import { Linking } from 'react-native';
import { create } from 'zustand';
import { getTestConfig } from './testConfig';

type ExternalLinkState = {
  capturedUrl: string | null;
  errorMessage: string | null;
  /** Opens `url` — in captureExternalLinks mode, just records it for deterministic assertion;
   * otherwise performs the real external launch and surfaces `errorMessage` on failure instead
   * of throwing/crashing or silently doing nothing. */
  open: (url: string) => Promise<void>;
  clear: () => void;
};

export const useExternalLinkStore = create<ExternalLinkState>((set) => ({
  capturedUrl: null,
  errorMessage: null,

  open: async (url: string) => {
    const cfg = getTestConfig();
    if (cfg.captureExternalLinks) {
      set({ capturedUrl: url, errorMessage: null });
      return;
    }
    try {
      await Linking.openURL(url);
      set({ capturedUrl: url, errorMessage: null });
    } catch (err) {
      const message = err instanceof Error ? err.message : 'Could not open the external link.';
      set({ errorMessage: message, capturedUrl: null });
    }
  },

  clear: () => set({ capturedUrl: null, errorMessage: null }),
}));
