import { Video } from './types';

// Filters to a single category (the source channel's configured label). `null`/`undefined`
// category means "no filter" — the full list. Pure, case-insensitive.
export function filterVideosByCategory(videos: Video[], category: string | null | undefined): Video[] {
  if (!category) return videos;
  const needle = category.trim().toLowerCase();
  return videos.filter((v) => v.category.trim().toLowerCase() === needle);
}
