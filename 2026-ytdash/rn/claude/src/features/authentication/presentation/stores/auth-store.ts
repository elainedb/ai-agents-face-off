import { create } from 'zustand';
import { User } from '../../domain/entities/user';
import { getContainer } from '../../../../core/di/container';

export type AuthStatus = 'initial' | 'loading' | 'authenticated' | 'unauthenticated' | 'error';

export interface AuthState {
  status: AuthStatus;
  user: User | null;
  errorMessage: string | null;
  checkAuthStatus: () => Promise<void>;
  signIn: () => Promise<void>;
  signOut: () => Promise<void>;
}

export const useAuthStore = create<AuthState>((set) => ({
  status: 'initial',
  user: null,
  errorMessage: null,

  checkAuthStatus: async () => {
    try {
      const container = getContainer();
      const result = await container.getCurrentUser.execute();
      if (result.ok) {
        if (result.data) {
          set({ status: 'authenticated', user: result.data, errorMessage: null });
        } else {
          set({ status: 'unauthenticated', user: null, errorMessage: null });
        }
      } else {
        set({ status: 'unauthenticated', user: null, errorMessage: null });
      }
    } catch {
      set({ status: 'unauthenticated', user: null, errorMessage: null });
    }
  },

  signIn: async () => {
    set({ status: 'loading', errorMessage: null });
    try {
      const container = getContainer();
      const result = await container.signInWithGoogle.execute();
      if (result.ok) {
        set({ status: 'authenticated', user: result.data, errorMessage: null });
      } else {
        set({ status: 'error', errorMessage: result.error.message });
      }
    } catch {
      set({ status: 'error', errorMessage: 'An unexpected error occurred' });
    }
  },

  signOut: async () => {
    try {
      const container = getContainer();
      await container.signOut.execute();
    } catch {
      // ignore
    }
    set({ status: 'unauthenticated', user: null, errorMessage: null });
  },
}));
