import type { UseCase } from '@/src/core/usecases/usecase';
import type { Result } from '@/src/core/error/result';
import type { User } from '../entities/user';
import type { AuthRepository } from '../repositories/auth-repository';

export class GetCurrentUser implements UseCase<User | null, void> {
  constructor(private readonly repository: AuthRepository) {}

  async execute(): Promise<Result<User | null>> {
    return this.repository.getCurrentUser();
  }
}
