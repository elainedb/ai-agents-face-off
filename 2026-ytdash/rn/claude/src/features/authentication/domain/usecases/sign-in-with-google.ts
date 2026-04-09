import { UseCase } from '@/src/core/usecases/usecase';
import { Result } from '@/src/core/error/result';
import { User } from '../entities/user';
import { AuthRepository } from '../repositories/auth-repository';

export class SignInWithGoogle implements UseCase<User, void> {
  constructor(private readonly repository: AuthRepository) {}

  async execute(): Promise<Result<User>> {
    return this.repository.signInWithGoogle();
  }
}
