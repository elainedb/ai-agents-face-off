import { create } from 'zustand';
import { User } from '../../domain/entities/user';
import { container } from '@/src/core/di/container';

export type AuthStatus =
  | 'initial'
  | 'loading'
  | 'authenticated'
  | 'unauthenticated'
  | 'error';

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
  },

  signIn: async () => {
    set({ status: 'loading', errorMessage: null });
    const result = await container.signInWithGoogle.execute();
    if (result.ok) {
      set({ status: 'authenticated', user: result.data, errorMessage: null });
    } else {
      set({
        status: 'error',
        user: null,
        errorMessage: result.error.message,
      });
    }
  },

  signOut: async () => {
    await container.signOut.execute();
    set({ status: 'unauthenticated', user: null, errorMessage: null });
  },
}));
