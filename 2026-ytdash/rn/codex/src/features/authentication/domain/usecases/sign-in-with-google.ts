import { UseCase } from '@/src/core/usecases/usecase';
import { Result } from '@/src/core/error/result';
import { User } from '@/src/features/authentication/domain/entities/user';
import { AuthRepository } from '@/src/features/authentication/domain/repositories/auth-repository';

export class SignInWithGoogle implements UseCase<User, void> {
  constructor(private readonly authRepository: AuthRepository) {}

  execute(): Promise<Result<User>> {
    return this.authRepository.signInWithGoogle();
  }
}
