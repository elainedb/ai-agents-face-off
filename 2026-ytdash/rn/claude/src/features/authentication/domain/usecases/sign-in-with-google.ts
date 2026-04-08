import type { UseCase } from '@/src/core/usecases/usecase';
import type { Result } from '@/src/core/error/result';
import type { User } from '../entities/user';
import type { AuthRepository } from '../repositories/auth-repository';

export class SignInWithGoogle implements UseCase<User, void> {
  constructor(private readonly repository: AuthRepository) {}

  async execute(): Promise<Result<User>> {
    return this.repository.signInWithGoogle();
  }
}
