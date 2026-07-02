import { create } from 'zustand';

export type Screen = 'login' | 'home' | 'map';

type NavState = {
  screen: Screen;
  goLogin: () => void;
  goHome: () => void;
  goMap: () => void;
};

// A hand-rolled 3-screen stack — see plan.md "Structure Decision" for why no nav library is used.
export const useNavStore = create<NavState>((set) => ({
  screen: 'login',
  goLogin: () => set({ screen: 'login' }),
  goHome: () => set({ screen: 'home' }),
  goMap: () => set({ screen: 'map' }),
}));
