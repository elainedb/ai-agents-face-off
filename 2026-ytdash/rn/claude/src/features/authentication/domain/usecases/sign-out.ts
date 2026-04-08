import type { UseCase } from '@/src/core/usecases/usecase';
import type { Result } from '@/src/core/error/result';
import type { AuthRepository } from '../repositories/auth-repository';

export class SignOut implements UseCase<void, void> {
  constructor(private readonly repository: AuthRepository) {}

  async execute(): Promise<Result<void>> {
    return this.repository.signOut();
  }
}
