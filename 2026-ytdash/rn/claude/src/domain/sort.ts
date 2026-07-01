import { SortKey, Video } from './types';

// Pure sorting over the domain list (AC-SORT-01). Returns a new array; never mutates input.
export function sortVideos(videos: Video[], key: SortKey): Video[] {
  const copy = [...videos];
  switch (key) {
    case 'date_desc':
      return copy.sort((a, b) => dateValue(b) - dateValue(a));
    case 'date_asc':
      return copy.sort((a, b) => dateValue(a) - dateValue(b));
    case 'title_asc':
      return copy.sort((a, b) => a.title.localeCompare(b.title));
    case 'title_desc':
      return copy.sort((a, b) => b.title.localeCompare(a.title));
    default:
      return copy;
  }
}

function dateValue(v: Video): number {
  const t = Date.parse(v.publishedAt);
  return Number.isNaN(t) ? 0 : t;
}

export const SORT_OPTIONS: { key: SortKey; label: string }[] = [
  // Labels END with the regex keyword so Maestro's full-string `text:` match works
  // (cross-framework-setup §D.3): `(?i)date.*(desc|newest)` must match the whole label.
  { key: 'date_desc', label: 'Date — newest' },
  { key: 'date_asc', label: 'Date — oldest' },
  { key: 'title_asc', label: 'Title A–Z' },
  { key: 'title_desc', label: 'Title Z–A' },
];
