import { SortDirection, SortKey, Video } from './types';

export function filterByCategory(videos: Video[], category: string | null): Video[] {
  if (!category) return videos;
  const normalized = category.trim().toLowerCase();
  return videos.filter((v) => v.category.trim().toLowerCase() === normalized);
}

export function sortVideos(videos: Video[], key: SortKey, direction: SortDirection): Video[] {
  const sorted = [...videos].sort((a, b) => {
    if (key === 'date') {
      return new Date(a.publishedAt).getTime() - new Date(b.publishedAt).getTime();
    }
    return a.title.localeCompare(b.title);
  });
  return direction === 'desc' ? sorted.reverse() : sorted;
}

export function distinctCategories(videos: Video[]): string[] {
  return Array.from(new Set(videos.map((v) => v.category)));
}
