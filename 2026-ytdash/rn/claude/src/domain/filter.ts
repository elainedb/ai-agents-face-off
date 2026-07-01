import { Video } from './models';

// Distinct category labels present in the loaded data, in first-appearance order.
export function availableCategories(videos: Video[]): string[] {
  const seen: string[] = [];
  for (const v of videos) {
    if (v.category && !seen.includes(v.category)) seen.push(v.category);
  }
  return seen;
}

// Filter to a single category label; null = no filter (show all).
export function filterByCategory(videos: Video[], category: string | null): Video[] {
  if (!category) return videos;
  return videos.filter((v) => v.category === category);
}
