import { create } from 'zustand';

import type { User } from '@/src/features/authentication/domain/entities/user';
import type { GetCurrentUser } from '@/src/features/authentication/domain/usecases/get-current-user';
import type { SignInWithGoogle } from '@/src/features/authentication/domain/usecases/sign-in-with-google';
import type { SignOut } from '@/src/features/authentication/domain/usecases/sign-out';

export type AuthStatus = 'initial' | 'loading' | 'authenticated' | 'unauthenticated' | 'error';

interface AuthState {
  status: AuthStatus;
  user: User | null;
  errorMessage: string | null;
  checkAuthStatus: () => Promise<void>;
  signIn: () => Promise<boolean>;
  signOut: () => Promise<void>;
}

interface AuthStoreDependencies {
  getCurrentUser: GetCurrentUser;
  signInWithGoogle: SignInWithGoogle;
  signOutUseCase: SignOut;
}

export const createAuthStore = (dependencies: AuthStoreDependencies) =>
  create<AuthState>((set) => ({
    status: 'initial',
    user: null,
    errorMessage: null,
    checkAuthStatus: async () => {
      const result = await dependencies.getCurrentUser.execute();

      if (result.ok && result.data) {
        set({ status: 'authenticated', user: result.data, errorMessage: null });
        return;
      }

      if (result.ok) {
        set({ status: 'unauthenticated', user: null, errorMessage: null });
        return;
      }

      set({
        status: 'error',
        user: null,
        errorMessage: result.error.message,
      });
    },
    signIn: async () => {
      set({ status: 'loading', errorMessage: null });

      const result = await dependencies.signInWithGoogle.execute();

      if (result.ok) {
        set({
          status: 'authenticated',
          user: result.data,
          errorMessage: null,
        });
        return true;
      }

      set({
        status: 'error',
        user: null,
        errorMessage: result.error.message,
      });

      return false;
    },
    signOut: async () => {
      await dependencies.signOutUseCase.execute();
      set({ status: 'unauthenticated', user: null, errorMessage: null });
    },
  }));
