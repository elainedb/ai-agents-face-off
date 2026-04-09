import { authorizedEmails } from '@/src/config/auth-config';
import { failure, failureFromUnknown, Result, success } from '@/src/core/error/result';
import { AuthRemoteDataSource } from '@/src/features/authentication/data/datasources/auth-remote-datasource';
import { User } from '@/src/features/authentication/domain/entities/user';
import { AuthRepository } from '@/src/features/authentication/domain/repositories/auth-repository';

const ACCESS_DENIED_MESSAGE = 'Access denied. Your email is not authorized.';

export class AuthRepositoryImpl implements AuthRepository {
  constructor(private readonly remoteDataSource: AuthRemoteDataSource) {}

  async signInWithGoogle(): Promise<Result<User>> {
    try {
      const user = (await this.remoteDataSource.signInWithGoogle()).toEntity();

      if (!this.isAuthorized(user.email)) {
        await this.remoteDataSource.signOut();
        return failure({ type: 'auth', message: ACCESS_DENIED_MESSAGE });
      }

      return success(user);
    } catch (error) {
      return failure(failureFromUnknown(error));
    }
  }

  async signOut(): Promise<Result<void>> {
    try {
      await this.remoteDataSource.signOut();
      return success(undefined);
    } catch (error) {
      return failure(failureFromUnknown(error));
    }
  }

  async getCurrentUser(): Promise<Result<User | null>> {
    try {
      const user = await this.remoteDataSource.getCurrentUser();

      if (!user) {
        return success(null);
      }

      if (!this.isAuthorized(user.email)) {
        await this.remoteDataSource.signOut();
        return failure({ type: 'auth', message: ACCESS_DENIED_MESSAGE });
      }

      return success(user.toEntity());
    } catch (error) {
      return failure(failureFromUnknown(error));
    }
  }

  private isAuthorized(email: string): boolean {
    return authorizedEmails.map((item) => item.toLowerCase()).includes(email.toLowerCase());
  }
}
