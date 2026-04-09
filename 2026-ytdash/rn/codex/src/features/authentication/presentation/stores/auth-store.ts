import { create } from 'zustand';

import { initAuthContainer } from '@/src/core/di/container';
import type { User } from '@/src/features/authentication/domain/entities/user';

export type AuthStatus = 'initial' | 'loading' | 'authenticated' | 'unauthenticated' | 'error';

interface AuthState {
  status: AuthStatus;
  user: User | null;
  errorMessage: string | null;
  checkAuthStatus: () => Promise<boolean>;
  signIn: () => Promise<boolean>;
  signOut: () => Promise<void>;
  clearError: () => void;
}

const withTimeout = async <T>(promise: Promise<T>, timeoutMs: number, message: string): Promise<T> => {
  let timeoutId: ReturnType<typeof setTimeout> | undefined;

  const timeoutPromise = new Promise<T>((_, reject) => {
    timeoutId = setTimeout(() => {
      reject(new Error(message));
    }, timeoutMs);
  });

  try {
    return await Promise.race([promise, timeoutPromise]);
  } finally {
    if (timeoutId) {
      clearTimeout(timeoutId);
    }
  }
};

export const useAuthStore = create<AuthState>((set) => ({
  status: 'initial',
  user: null,
  errorMessage: null,
  async checkAuthStatus() {
    set({ status: 'loading', errorMessage: null });

    try {
      const container = await withTimeout(
        initAuthContainer(),
        5000,
        'App initialization timed out while checking your session.'
      );
      const result = await withTimeout(
        container.getCurrentUser.execute(),
        5000,
        'Session check timed out.'
      );

      if (!result.ok) {
        set({
          status: 'error',
          user: null,
          errorMessage: result.error.message,
        });
        return false;
      }

      set({
        status: result.data ? 'authenticated' : 'unauthenticated',
        user: result.data,
        errorMessage: null,
      });
      return Boolean(result.data);
    } catch (error) {
      set({
        status: 'error',
        user: null,
        errorMessage: error instanceof Error ? error.message : 'Unable to check the current session.',
      });
      return false;
    }
  },
  async signIn() {
    set({ status: 'loading', errorMessage: null });

    try {
      const container = await withTimeout(
        initAuthContainer(),
        5000,
        'App initialization timed out before sign-in started.'
      );
      const result = await withTimeout(
        container.signInWithGoogle.execute(),
        15000,
        'Google Sign-In timed out.'
      );

      if (!result.ok) {
        set({
          status: 'error',
          user: null,
          errorMessage: result.error.message,
        });
        return false;
      }

      set({
        status: 'authenticated',
        user: result.data,
        errorMessage: null,
      });
      return true;
    } catch (error) {
      set({
        status: 'error',
        user: null,
        errorMessage: error instanceof Error ? error.message : 'Unable to sign in.',
      });
      return false;
    }
  },
  async signOut() {
    try {
      const container = await withTimeout(
        initAuthContainer(),
        5000,
        'App initialization timed out before sign-out.'
      );
      await withTimeout(container.signOut.execute(), 5000, 'Sign-out timed out.');
    } finally {
      set({
        status: 'unauthenticated',
        user: null,
        errorMessage: null,
      });
    }
  },
  clearError() {
    set({ errorMessage: null, status: 'unauthenticated' });
  },
}));
