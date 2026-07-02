import { create } from 'zustand';
import { isAuthorizedEmail } from '../domain/auth';
import { getTestConfig } from './testConfig';

export type AuthStatus = 'signedOut' | 'signedIn' | 'unauthorized';

type AuthState = {
  status: AuthStatus;
  email: string | null;
  errorMessage: string | null;
  /** Test mode: skip the real Google picker, sign in as `mockAuthEmail`, then run whitelist logic. */
  signInWithMockEmail: () => void;
  /** Real mode: called with the email returned by the Google OAuth flow. */
  signInWithEmail: (email: string) => void;
  signInFailed: (message: string) => void;
  signOut: () => void;
};

export const useAuthStore = create<AuthState>((set) => ({
  status: 'signedOut',
  email: null,
  errorMessage: null,

  signInWithMockEmail: () => {
    const cfg = getTestConfig();
    const email = cfg.mockAuthEmail ?? '';
    if (isAuthorizedEmail(email, cfg.authorizedEmails)) {
      set({ status: 'signedIn', email, errorMessage: null });
    } else {
      set({ status: 'unauthorized', email, errorMessage: `${email || 'This account'} is not authorized.` });
    }
  },

  signInWithEmail: (email: string) => {
    const cfg = getTestConfig();
    if (isAuthorizedEmail(email, cfg.authorizedEmails)) {
      set({ status: 'signedIn', email, errorMessage: null });
    } else {
      set({ status: 'unauthorized', email, errorMessage: `${email} is not authorized.` });
    }
  },

  signInFailed: (message: string) => {
    set({ status: 'signedOut', email: null, errorMessage: message });
  },

  signOut: () => {
    set({ status: 'signedOut', email: null, errorMessage: null });
  },
}));
