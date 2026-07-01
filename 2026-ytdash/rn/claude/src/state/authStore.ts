import { create } from 'zustand';
import { AppConfig } from '../appConfig';
import { isAuthorized } from '../domain/auth';

type AuthState = {
  email: string | null;
  loggedIn: boolean;
  errorMessage: string | null;
  // Signs in with a resolved email (mock mode supplies it; real Google sign-in would too), then
  // applies the whitelist rule. Returns whether access was granted.
  signInWithEmail: (email: string | null, cfg: AppConfig) => boolean;
  logout: () => void;
};

export const useAuthStore = create<AuthState>((set) => ({
  email: null,
  loggedIn: false,
  errorMessage: null,
  signInWithEmail: (email, cfg) => {
    if (isAuthorized(email, cfg.authorizedEmails)) {
      set({ email, loggedIn: true, errorMessage: null });
      return true;
    }
    set({
      loggedIn: false,
      errorMessage: email
        ? `Access denied: ${email} is not an authorized account.`
        : 'Sign-in failed. Please try again.',
    });
    return false;
  },
  logout: () => set({ email: null, loggedIn: false, errorMessage: null }),
}));
