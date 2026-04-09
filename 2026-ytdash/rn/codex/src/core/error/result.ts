import {
  AppException,
  AuthException,
  CacheException,
  NetworkException,
  ServerException,
  ValidationException,
} from '@/src/core/error/exceptions';
import { Failure } from '@/src/core/error/failures';

export type Result<T> = { ok: true; data: T } | { ok: false; error: Failure };

export const success = <T>(data: T): Result<T> => ({ ok: true, data });

export const failure = <T>(error: Failure): Result<T> => ({ ok: false, error });

export const failureFromUnknown = (error: unknown): Failure => {
  if (error instanceof AuthException) {
    return { type: 'auth', message: error.message };
  }

  if (error instanceof NetworkException) {
    return { type: 'network', message: error.message };
  }

  if (error instanceof CacheException) {
    return { type: 'cache', message: error.message };
  }

  if (error instanceof ServerException) {
    return { type: 'server', message: error.message };
  }

  if (error instanceof ValidationException) {
    return { type: 'validation', message: error.message };
  }

  if (error instanceof AppException) {
    return { type: 'unexpected', message: error.message };
  }

  if (error instanceof Error) {
    return { type: 'unexpected', message: error.message };
  }

  return { type: 'unexpected', message: 'An unexpected error occurred.' };
};
