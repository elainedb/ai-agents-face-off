import { SortDirection, SortKey, Video } from './types';

// Sorts by publishedAt (currently the only supported key). Pure — returns a new array, never
// mutates the input, so the store can call it freely from any state shape.
export function sortVideos(videos: Video[], _key: SortKey, direction: SortDirection): Video[] {
  const sorted = [...videos].sort((a, b) => Date.parse(a.publishedAt) - Date.parse(b.publishedAt));
  return direction === 'desc' ? sorted.reverse() : sorted;
}
