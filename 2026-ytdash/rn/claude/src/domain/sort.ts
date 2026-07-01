import { Video } from './models';

export type SortKey = 'default' | 'date-desc' | 'date-asc' | 'title-asc' | 'title-desc';

export const SORT_OPTIONS: { key: SortKey; label: string }[] = [
  // Labels must END with the harness keyword — Maestro `text:` is a full-string match, so
  // "Date — newest" matches `(?i)date.*(desc|newest)` but "Date newest first" would not.
  { key: 'date-desc', label: 'Date — newest' },
  { key: 'date-asc', label: 'Date — oldest' },
  { key: 'title-asc', label: 'Title — A to Z' },
  { key: 'title-desc', label: 'Title — Z to A' },
];

export function sortVideos(videos: Video[], key: SortKey): Video[] {
  const copy = [...videos];
  switch (key) {
    case 'default':
      // Preserve API/aggregation order (first channel's first page first) until the user sorts.
      return copy;
    case 'date-desc':
      return copy.sort((a, b) => b.publishedAt.localeCompare(a.publishedAt));
    case 'date-asc':
      return copy.sort((a, b) => a.publishedAt.localeCompare(b.publishedAt));
    case 'title-asc':
      return copy.sort((a, b) => a.title.localeCompare(b.title));
    case 'title-desc':
      return copy.sort((a, b) => b.title.localeCompare(a.title));
    default:
      return copy;
  }
}
