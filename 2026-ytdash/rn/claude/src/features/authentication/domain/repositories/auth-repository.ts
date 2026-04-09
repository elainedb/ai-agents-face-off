import { Result } from '@/src/core/error/result';
import { User } from '../entities/user';

export interface AuthRepository {
  signInWithGoogle(): Promise<Result<User>>;
  signOut(): Promise<Result<void>>;
  getCurrentUser(): Promise<Result<User | null>>;
}
