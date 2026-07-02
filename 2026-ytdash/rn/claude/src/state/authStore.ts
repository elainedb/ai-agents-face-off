import { create } from 'zustand';

import { isAuthorized } from '../domain/auth';
import { signInWithGoogle } from '../native/googleAuth';
import { useTestConfigStore } from './testConfigStore';

type AuthStatus = 'signed_out' | 'signed_in';

type AuthState = {
  status: AuthStatus;
  email: string | null;
  errorMessage: string | null;
  signIn: () => Promise<void>;
  signOut: () => void;
};

export const useAuthStore = create<AuthState>((set) => ({
  status: 'signed_out',
  email: null,
  errorMessage: null,

  signIn: async () => {
    const cfg = useTestConfigStore.getState();
    set({ errorMessage: null });

    let email: string | null;
    try {
      email = cfg.uiTestMode && cfg.mockAuthEmail ? cfg.mockAuthEmail : await signInWithGoogle();
    } catch (cause) {
      set({ errorMessage: cause instanceof Error ? cause.message : 'Sign-in failed.' });
      return;
    }

    if (!email) {
      // Cancelled by the user — not an error state, just stay on the login screen.
      return;
    }

    if (isAuthorized(email, cfg.authorizedEmails)) {
      set({ status: 'signed_in', email, errorMessage: null });
    } else {
      set({ status: 'signed_out', email: null, errorMessage: `${email} is not authorized to use this app.` });
    }
  },

  signOut: () => set({ status: 'signed_out', email: null, errorMessage: null }),
}));
