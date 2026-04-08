import { authorizedEmails } from '@/src/config/auth-config';
import { err, ok, type Result } from '@/src/core/error/result';
import type { User } from '@/src/features/authentication/domain/entities/user';
import type { AuthRepository } from '@/src/features/authentication/domain/repositories/auth-repository';
import { AuthRemoteDataSource } from '@/src/features/authentication/data/datasources/auth-remote-datasource';

const unauthorizedResult = err<User>({
  type: 'auth',
  message: 'Access denied. Your email is not authorized.',
});

export class AuthRepositoryImpl implements AuthRepository {
  constructor(private readonly authRemoteDataSource: AuthRemoteDataSource) {}

  private async ensureAuthorized(user: User): Promise<Result<User>> {
    const normalizedEmails = authorizedEmails.map((email) => email.trim().toLowerCase());

    if (!normalizedEmails.includes(user.email.trim().toLowerCase())) {
      await this.authRemoteDataSource.signOut();
      return unauthorizedResult;
    }

    return ok(user);
  }

  async signInWithGoogle(): Promise<Result<User>> {
    try {
      const user = (await this.authRemoteDataSource.signInWithGoogle()).toEntity();
      return this.ensureAuthorized(user);
    } catch (error) {
      return err({
        type: 'auth',
        message: error instanceof Error ? error.message : 'Unable to sign in.',
      });
    }
  }

  async signOut(): Promise<Result<void>> {
    try {
      await this.authRemoteDataSource.signOut();
      return ok(undefined);
    } catch (error) {
      return err({
        type: 'auth',
        message: error instanceof Error ? error.message : 'Unable to sign out.',
      });
    }
  }

  async getCurrentUser(): Promise<Result<User | null>> {
    try {
      const userModel = await this.authRemoteDataSource.getCurrentUser();

      if (!userModel) {
        return ok(null);
      }

      const authorized = await this.ensureAuthorized(userModel.toEntity());
      return authorized.ok ? ok(authorized.data) : authorized;
    } catch (error) {
      return err({
        type: 'auth',
        message: error instanceof Error ? error.message : 'Unable to read auth state.',
      });
    }
  }
}
