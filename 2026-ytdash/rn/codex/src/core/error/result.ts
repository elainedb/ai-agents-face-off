import type { Failure } from '@/src/core/error/failures';

export type Result<T> = { ok: true; data: T } | { ok: false; error: Failure };

export const success = <T>(data: T): Result<T> => ({ ok: true, data });

export const failure = <T>(error: Failure): Result<T> => ({ ok: false, error });
