import { Video } from '../data/types';

export type SortKey = 'date' | 'title';
export type SortDir = 'asc' | 'desc';
export type SortOption = { key: SortKey; dir: SortDir };

export const SORT_OPTIONS: { label: string; option: SortOption }[] = [
  // Labels END with the regex keyword so Maestro's full-string `text:` match works
  // (cross-framework-setup §D.3): `(?i)date.*(desc|newest)` matches "Date — Newest".
  { label: 'Date — Newest', option: { key: 'date', dir: 'desc' } },
  { label: 'Date — Oldest', option: { key: 'date', dir: 'asc' } },
  { label: 'Title — A-Z', option: { key: 'title', dir: 'asc' } },
  { label: 'Title — Z-A', option: { key: 'title', dir: 'desc' } },
];

export function sortVideos(videos: Video[], option: SortOption): Video[] {
  const copy = [...videos];
  copy.sort((a, b) => {
    let cmp: number;
    if (option.key === 'date') {
      cmp = Date.parse(a.publishedAt) - Date.parse(b.publishedAt);
      if (Number.isNaN(cmp)) cmp = a.publishedAt.localeCompare(b.publishedAt);
    } else {
      cmp = a.title.localeCompare(b.title, undefined, { sensitivity: 'base' });
    }
    return option.dir === 'asc' ? cmp : -cmp;
  });
  return copy;
}
