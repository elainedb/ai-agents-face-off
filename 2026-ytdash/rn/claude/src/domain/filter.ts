import { ALL_FILTER, Video } from './types';

// Filter by source-channel label (spec: displayed "category" = configured channel label).
// AC-FILTER-01 filters to the first channel's label; case-insensitive match. Pure + unit-tested.
export function filterVideos(videos: Video[], label: string): Video[] {
  if (!label || label === ALL_FILTER) return videos;
  const target = label.trim().toLowerCase();
  return videos.filter((v) => v.category.trim().toLowerCase() === target);
}

// The distinct category labels present in the data, in first-appearance order (for the filter panel).
export function availableLabels(videos: Video[]): string[] {
  const seen: string[] = [];
  for (const v of videos) {
    if (v.category && !seen.includes(v.category)) seen.push(v.category);
  }
  return seen;
}
