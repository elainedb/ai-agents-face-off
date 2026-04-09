import { AuthException } from '../../../../core/error/exceptions';
import { Result } from '../../../../core/error/result';
import { authorizedEmails } from '../../../../config/auth-config';
import { User } from '../../domain/entities/user';
import { AuthRepository } from '../../domain/repositories/auth-repository';
import { AuthRemoteDataSource } from '../datasources/auth-remote-datasource';

export class AuthRepositoryImpl implements AuthRepository {
  constructor(private remoteDataSource: AuthRemoteDataSource) {}

  async signInWithGoogle(): Promise<Result<User>> {
    try {
      const userModel = await this.remoteDataSource.signInWithGoogle();
      const user = userModel.toEntity();
      if (!authorizedEmails.includes(user.email)) {
        await this.remoteDataSource.signOut();
        return { ok: false, error: { type: 'auth', message: 'Access denied. Your email is not authorized.' } };
      }
      return { ok: true, data: user };
    } catch (error: unknown) {
      if (error instanceof AuthException) {
        return { ok: false, error: { type: 'auth', message: error.message } };
      }
      return { ok: false, error: { type: 'unexpected', message: String(error) } };
    }
  }

  async signOut(): Promise<Result<void>> {
    try {
      await this.remoteDataSource.signOut();
      return { ok: true, data: undefined };
    } catch (error: unknown) {
      if (error instanceof AuthException) {
        return { ok: false, error: { type: 'auth', message: error.message } };
      }
      return { ok: false, error: { type: 'unexpected', message: String(error) } };
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
    } catch (error: unknown) {
      if (error instanceof AuthException) {
        return { ok: false, error: { type: 'auth', message: error.message } };
      }
      return { ok: false, error: { type: 'unexpected', message: String(error) } };
    }
  }
}
