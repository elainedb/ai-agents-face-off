export type VideoLocation = {
  lat: number;
  lng: number;
};

export type Video = {
  id: string;
  title: string;
  description: string;
  publishedAt: string; // ISO-8601
  category: string; // the source channel's configured label
  thumbnailUrl: string;
  location: VideoLocation | null;
  youtubeUrl: string;
};

export type UiStatus = 'loading' | 'content' | 'empty' | 'error';

export type AppError = {
  message: string;
  cause?: unknown;
};

export type Result<T> = { ok: true; value: T } | { ok: false; error: AppError };

export function ok<T>(value: T): Result<T> {
  return { ok: true, value };
}

export function err<T>(message: string, cause?: unknown): Result<T> {
  return { ok: false, error: { message, cause } };
}

export type SortKey = 'date';
export type SortDirection = 'asc' | 'desc';
