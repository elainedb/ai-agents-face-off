import { Video } from '../data/types';

/** Distinct category labels present in the data, in first-appearance (channel) order. */
export function availableCategories(videos: Video[]): string[] {
  const seen = new Set<string>();
  const out: string[] = [];
  for (const v of videos) {
    if (v.category && !seen.has(v.category)) {
      seen.add(v.category);
      out.push(v.category);
    }
  }
  return out;
}

/**
 * Filter by category label (spec: "category = source-channel label", AC-FILTER-01).
 * `category === null` means "all".
 */
export function filterVideos(videos: Video[], category: string | null): Video[] {
  if (!category) return videos;
  const target = category.trim().toLowerCase();
  return videos.filter((v) => v.category.trim().toLowerCase() === target);
}
