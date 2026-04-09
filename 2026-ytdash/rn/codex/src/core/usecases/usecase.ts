import { Result } from '@/src/core/error/result';

export interface UseCase<T, P> {
  execute(params: P): Promise<Result<T>>;
}
