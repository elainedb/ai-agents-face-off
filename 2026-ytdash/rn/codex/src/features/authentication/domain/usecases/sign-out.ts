import { Result } from '@/src/core/error/result';
import { UseCase } from '@/src/core/usecases/usecase';
import { AuthRepository } from '@/src/features/authentication/domain/repositories/auth-repository';

export class SignOut implements UseCase<void, void> {
  constructor(private readonly authRepository: AuthRepository) {}

  execute(): Promise<Result<void>> {
    return this.authRepository.signOut();
  }
}
