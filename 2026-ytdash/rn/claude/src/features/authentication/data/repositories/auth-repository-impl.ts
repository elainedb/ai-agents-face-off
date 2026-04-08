import type { Result } from '@/src/core/error/result';
import type { User } from '../../domain/entities/user';
import type { AuthRepository } from '../../domain/repositories/auth-repository';
import type { AuthRemoteDataSource } from '../datasources/auth-remote-datasource';
import { authorizedEmails } from '@/src/config/auth-config';
import { AuthException } from '@/src/core/error/exceptions';

export class AuthRepositoryImpl implements AuthRepository {
  constructor(private readonly remote: AuthRemoteDataSource) {}

  async signInWithGoogle(): Promise<Result<User>> {
    try {
      const userModel = await this.remote.signInWithGoogle();
      const user = userModel.toEntity();

      if (!authorizedEmails.includes(user.email)) {
        await this.remote.signOut();
        return { ok: false, error: { type: 'auth', message: 'Access denied. Your email is not authorized.' } };
      }

      return { ok: true, data: user };
    } catch (error) {
      const message = error instanceof AuthException ? error.message : 'An unexpected error occurred during sign-in';
      return { ok: false, error: { type: 'auth', message } };
    }
  }

  async signOut(): Promise<Result<void>> {
    try {
      await this.remote.signOut();
      return { ok: true, data: undefined };
    } catch (error) {
      const message = error instanceof Error ? error.message : 'An unexpected error occurred during sign-out';
      return { ok: false, error: { type: 'auth', message } };
    }
  }

  async getCurrentUser(): Promise<Result<User | null>> {
    try {
      const userModel = await this.remote.getCurrentUser();
      if (!userModel) {
        return { ok: true, data: null };
      }

      const user = userModel.toEntity();

      if (!authorizedEmails.includes(user.email)) {
        await this.remote.signOut();
        return { ok: true, data: null };
      }

      return { ok: true, data: user };
    } catch (error) {
      const message = error instanceof Error ? error.message : 'An unexpected error occurred';
      return { ok: false, error: { type: 'auth', message } };
    }
  }
}
