import { create } from 'zustand';

export type Screen = 'home' | 'map';

type NavState = {
  screen: Screen;
  go: (screen: Screen) => void;
};

export const useNavStore = create<NavState>((set) => ({
  screen: 'home',
  go: (screen) => set({ screen }),
}));
