import { Linking } from 'react-native';
import { create } from 'zustand';

import { useTestConfigStore } from './testConfigStore';

type ExternalLinkState = {
  capturedUrl: string | null;
  errorMessage: string | null;
  open: (url: string) => Promise<void>;
  clear: () => void;
};

// Lives at the app root (mounted once in App.tsx) so both the video list (iteration 2) and the
// map's detail sheet (iteration 4) share one `external_open_url`/`external_open_error` surface
// (constitution §3, cross-framework-setup.md §C note 1).
export const useExternalLinkStore = create<ExternalLinkState>((set) => ({
  capturedUrl: null,
  errorMessage: null,

  open: async (url) => {
    const cfg = useTestConfigStore.getState();

    if (cfg.captureExternalLinks) {
      set({ capturedUrl: url, errorMessage: null });
      return;
    }

    try {
      await Linking.openURL(url);
      set({ capturedUrl: null, errorMessage: null });
    } catch {
      set({ capturedUrl: null, errorMessage: 'Could not open the video externally.' });
    }
  },

  clear: () => set({ capturedUrl: null, errorMessage: null }),
}));
