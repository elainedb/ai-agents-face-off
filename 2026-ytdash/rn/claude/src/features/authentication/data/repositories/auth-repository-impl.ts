import { Result } from '@/src/core/error/result';
import { AuthException } from '@/src/core/error/exceptions';
import { User } from '../../domain/entities/user';
import { AuthRepository } from '../../domain/repositories/auth-repository';
import { AuthRemoteDataSource } from '../datasources/auth-remote-datasource';
import { authorizedEmails } from '@/src/config/auth-config';

export class AuthRepositoryImpl implements AuthRepository {
  constructor(private readonly remoteDataSource: AuthRemoteDataSource) {}

  async signInWithGoogle(): Promise<Result<User>> {
    try {
      const userModel = await this.remoteDataSource.signInWithGoogle();
      const user = userModel.toEntity();
      if (!authorizedEmails.includes(user.email)) {
        await this.remoteDataSource.signOut();
        return {
          ok: false,
          error: {
            type: 'auth',
            message: 'Access denied. Your email is not authorized.',
          },
        };
      }
      return { ok: true, data: user };
    } catch (error) {
      return {
        ok: false,
        error: {
          type: 'auth',
          message:
            error instanceof AuthException
              ? error.message
              : 'Authentication failed',
        },
      };
    }
  }

  async signOut(): Promise<Result<void>> {
    try {
      await this.remoteDataSource.signOut();
      return { ok: true, data: undefined };
    } catch (error) {
      return {
        ok: false,
        error: {
          type: 'auth',
          message:
            error instanceof Error ? error.message : 'Sign out failed',
        },
      };
    }
  }

  async getCurrentUser(): Promise<Result<User | null>> {
    try {
      const userModel = await this.remoteDataSource.getCurrentUser();
      if (!userModel) return { ok: true, data: null };
      const user = userModel.toEntity();
      if (!authorizedEmails.includes(user.email)) {
        await this.remoteDataSource.signOut();
        return { ok: true, data: null };
      }
      return { ok: true, data: user };
    } catch (error) {
      return {
        ok: false,
        error: {
          type: 'auth',
          message:
            error instanceof Error
              ? error.message
              : 'Failed to get current user',
        },
      };
    }
  }
}
