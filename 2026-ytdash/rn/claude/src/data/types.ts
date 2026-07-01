import { z } from 'zod';

/** Domain model the UI renders from. Populated purely from API responses — never fixtures. */
export type Video = {
  id: string;
  title: string;
  description: string;
  publishedAt: string; // ISO-8601
  category: string; // source-channel label
  thumbnailUrl: string | null;
  lat: number | null;
  lng: number | null;
  youtubeUrl: string; // https://www.youtube.com/watch?v=<id>
};

export function isLocated(v: Video): v is Video & { lat: number; lng: number } {
  return typeof v.lat === 'number' && typeof v.lng === 'number';
}

export function youtubeUrlFor(id: string): string {
  return `https://www.youtube.com/watch?v=${id}`;
}

/** Explicit success/failure — every failure point resolves to a typed error (constitution §1.6). */
export type Result<T> = { ok: true; value: T } | { ok: false; error: AppError };

export type AppErrorKind = 'network' | 'parse' | 'auth' | 'persistence' | 'unknown';
export type AppError = { kind: AppErrorKind; message: string };

export function ok<T>(value: T): Result<T> {
  return { ok: true, value };
}
export function err(kind: AppErrorKind, message: string): Result<never> {
  return { ok: false, error: { kind, message } };
}

/** Sealed view-state (constitution §1.3): loading / content / empty / error. */
export type UiStatus = 'idle' | 'loading' | 'content' | 'empty' | 'error';

// ---- Zod schemas for the YouTube Data API v3 shapes (see spec/youtube-api.md) ----

const Thumbnail = z.object({ url: z.string() }).partial();
const Thumbnails = z
  .object({ default: Thumbnail, medium: Thumbnail, high: Thumbnail })
  .partial();

const SearchSnippet = z.object({
  publishedAt: z.string().optional(),
  title: z.string().optional(),
  description: z.string().optional(),
  channelTitle: z.string().optional(),
  thumbnails: Thumbnails.optional(),
});

export const SearchListResponse = z.object({
  nextPageToken: z.string().optional(),
  items: z
    .array(
      z.object({
        id: z.object({ videoId: z.string().optional() }).optional(),
        snippet: SearchSnippet.optional(),
        // playlistItems idiom carries the id under snippet.resourceId
      }),
    )
    .default([]),
});

export const PlaylistItemsResponse = z.object({
  nextPageToken: z.string().optional(),
  items: z
    .array(
      z.object({
        snippet: SearchSnippet.extend({
          resourceId: z.object({ videoId: z.string().optional() }).optional(),
        }).optional(),
      }),
    )
    .default([]),
});

const Location = z.object({ latitude: z.number(), longitude: z.number() });

export const VideosListResponse = z.object({
  items: z
    .array(
      z.object({
        id: z.string(),
        snippet: SearchSnippet.optional(),
        recordingDetails: z.object({ location: Location.optional() }).optional(),
      }),
    )
    .default([]),
});
