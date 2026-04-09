import { Result } from '@/src/core/error/result';
import { UseCase } from '@/src/core/usecases/usecase';
import { User } from '@/src/features/authentication/domain/entities/user';
import { AuthRepository } from '@/src/features/authentication/domain/repositories/auth-repository';

export class GetCurrentUser implements UseCase<User | null, void> {
  constructor(private readonly authRepository: AuthRepository) {}

  execute(): Promise<Result<User | null>> {
    return this.authRepository.getCurrentUser();
  }
}
