import { UseCase } from '@/src/core/usecases/usecase';
import { Result } from '@/src/core/error/result';
import { AuthRepository } from '../repositories/auth-repository';

export class SignOut implements UseCase<void, void> {
  constructor(private readonly repository: AuthRepository) {}

  async execute(): Promise<Result<void>> {
    return this.repository.signOut();
  }
}
