import type { SortKey, Video } from './models';

export function sortVideos(videos: Video[], key: SortKey): Video[] {
  const copy = [...videos];
  switch (key) {
    case 'date-desc':
      return copy.sort((a, b) => Date.parse(b.publishedAt) - Date.parse(a.publishedAt));
    case 'date-asc':
      return copy.sort((a, b) => Date.parse(a.publishedAt) - Date.parse(b.publishedAt));
    case 'title-asc':
      return copy.sort((a, b) => a.title.localeCompare(b.title));
    default:
      return copy;
  }
}

export function filterVideos(videos: Video[], label: string | null): Video[] {
  if (!label) return videos;
  return videos.filter((v) => v.category.toLowerCase() === label.toLowerCase());
}

export function distinctCategories(videos: Video[]): string[] {
  return Array.from(new Set(videos.map((v) => v.category))).sort();
}
