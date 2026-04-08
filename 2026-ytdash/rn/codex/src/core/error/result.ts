import type { Failure } from '@/src/core/error/failures';

export type Result<T> = { ok: true; data: T } | { ok: false; error: Failure };

export const ok = <T>(data: T): Result<T> => ({ ok: true, data });

export const err = <T = never>(error: Failure): Result<T> => ({ ok: false, error });
