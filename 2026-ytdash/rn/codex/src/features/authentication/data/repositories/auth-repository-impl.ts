import { authorizedEmails } from '@/src/config/auth-config';
import { AuthException } from '@/src/core/error/exceptions';
import { failure, success, type Result } from '@/src/core/error/result';
import type { User } from '@/src/features/authentication/domain/entities/user';
import type { AuthRepository } from '@/src/features/authentication/domain/repositories/auth-repository';
import { AuthRemoteDataSource } from '@/src/features/authentication/data/datasources/auth-remote-datasource';

const authorizedEmailSet = new Set(authorizedEmails.map((email) => email.trim().toLowerCase()));

export class AuthRepositoryImpl implements AuthRepository {
  constructor(private readonly authRemoteDataSource: AuthRemoteDataSource) {}

  async signInWithGoogle(): Promise<Result<User>> {
    try {
      const user = (await this.authRemoteDataSource.signInWithGoogle()).toEntity();
      if (!this.isAuthorized(user.email)) {
        await this.authRemoteDataSource.signOut();
        return failure({
          type: 'auth',
          message: 'Access denied. Your email is not authorized.',
        });
      }

      return success(user);
    } catch (error) {
      return this.mapError<User>(error, 'Unable to sign in.');
    }
  }

  async signOut(): Promise<Result<void>> {
    try {
      await this.authRemoteDataSource.signOut();
      return success(undefined);
    } catch (error) {
      return this.mapError<void>(error, 'Unable to sign out.');
    }
  }

  async getCurrentUser(): Promise<Result<User | null>> {
    try {
      const currentUser = await this.authRemoteDataSource.getCurrentUser();
      if (!currentUser) {
        return success(null);
      }

      const user = currentUser.toEntity();
      if (!this.isAuthorized(user.email)) {
        await this.authRemoteDataSource.signOut();
        return success(null);
      }

      return success(user);
    } catch (error) {
      return this.mapError<User | null>(error, 'Unable to check the current session.');
    }
  }

  private isAuthorized(email: string): boolean {
    return authorizedEmailSet.has(email.trim().toLowerCase());
  }

  private mapError<T>(error: unknown, fallbackMessage: string): Result<T> {
    if (error instanceof AuthException) {
      return failure({ type: 'auth', message: error.message });
    }

    if (error instanceof Error) {
      return failure({ type: 'unexpected', message: error.message });
    }

    return failure({ type: 'unexpected', message: fallbackMessage });
  }
}
