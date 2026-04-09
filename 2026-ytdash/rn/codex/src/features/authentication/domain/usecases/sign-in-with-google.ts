import type { Result } from '@/src/core/error/result';
import type { UseCase } from '@/src/core/usecases/usecase';
import type { User } from '@/src/features/authentication/domain/entities/user';
import type { AuthRepository } from '@/src/features/authentication/domain/repositories/auth-repository';

export class SignInWithGoogle implements UseCase<User, void> {
  constructor(private readonly authRepository: AuthRepository) {}

  execute(): Promise<Result<User>> {
    return this.authRepository.signInWithGoogle();
  }
}
