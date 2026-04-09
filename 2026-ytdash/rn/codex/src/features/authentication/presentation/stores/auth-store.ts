import { create } from 'zustand';

import { getContainer } from '@/src/core/di/container';
import { User } from '@/src/features/authentication/domain/entities/user';

export type AuthStatus = 'initial' | 'loading' | 'authenticated' | 'unauthenticated' | 'error';

interface AuthState {
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
    set((state) => ({
      ...state,
      status: 'loading',
      errorMessage: null,
    }));

    const result = await getContainer().getCurrentUser.execute();

    if (!result.ok) {
      set({
        status: 'error',
        user: null,
        errorMessage: result.error.message,
      });
      return;
    }

    set({
      status: result.data ? 'authenticated' : 'unauthenticated',
      user: result.data,
      errorMessage: null,
    });
  },
  signIn: async () => {
    set((state) => ({
      ...state,
      status: 'loading',
      errorMessage: null,
    }));

    const result = await getContainer().signInWithGoogle.execute();

    if (!result.ok) {
      set({
        status: 'error',
        user: null,
        errorMessage: result.error.message,
      });
      return;
    }

    set({
      status: 'authenticated',
      user: result.data,
      errorMessage: null,
    });
  },
  signOut: async () => {
    await getContainer().signOut.execute();
    set({
      status: 'unauthenticated',
      user: null,
      errorMessage: null,
    });
  },
}));
