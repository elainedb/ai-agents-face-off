import { Linking } from 'react-native';
import { create } from 'zustand';

// Cross-screen "open in YouTube" state. Lifted to the app root so both the list (iteration 2) and
// the map bottom sheet (iteration 4) feed the same banner (cross-framework-setup.md §C).
type ExternalState = {
  capturedUrl: string | null; // UI-test-mode capture (captureExternalLinks=true)
  error: boolean; // a real external launch was attempted and failed
  open: (url: string, capture: boolean) => Promise<void>;
  reset: () => void;
};

export const useExternalStore = create<ExternalState>((set) => ({
  capturedUrl: null,
  error: false,
  open: async (url, capture) => {
    if (capture) {
      // Deterministic correctness check: surface the exact target URL instead of launching.
      set({ capturedUrl: url, error: false });
      return;
    }
    // Production path: perform the real external launch; surface an error instead of crashing.
    try {
      await Linking.openURL(url);
      set({ error: false });
    } catch {
      set({ error: true });
    }
  },
  reset: () => set({ capturedUrl: null, error: false }),
}));
