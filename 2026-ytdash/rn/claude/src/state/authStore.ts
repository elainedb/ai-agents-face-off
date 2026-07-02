import { create } from 'zustand';
import Constants from 'expo-constants';

import { isAuthorizedEmail } from '../domain/auth';
import { loadTestConfig } from '../data/testConfig';

type AuthState = {
  email: string | null;
  authorized: boolean;
  deniedEmail: string | null;
  attemptLogin: (email: string) => void;
  logout: () => void;
};

function whitelistCsv(): string {
  const testConfig = loadTestConfig();
  if (testConfig.uiTestMode && testConfig.authorizedEmails) return testConfig.authorizedEmails;
  const fallback = (Constants.expoConfig?.extra as Record<string, string> | undefined)?.authorizedEmails;
  return fallback ?? '';
}

export const useAuthStore = create<AuthState>((set) => ({
  email: null,
  authorized: false,
  deniedEmail: null,
  attemptLogin: (email: string) => {
    if (isAuthorizedEmail(email, whitelistCsv())) {
      set({ email, authorized: true, deniedEmail: null });
    } else {
      set({ email: null, authorized: false, deniedEmail: email });
    }
  },
  logout: () => set({ email: null, authorized: false, deniedEmail: null }),
}));
