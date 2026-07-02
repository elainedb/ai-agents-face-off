import { filterVideosByCategory } from '../domain/filter';
import { Video } from '../domain/types';

function video(id: string, category: string): Video {
  return {
    id,
    title: id,
    description: '',
    publishedAt: '2026-01-01T00:00:00Z',
    category,
    thumbnailUrl: '',
    location: null,
    youtubeUrl: `https://www.youtube.com/watch?v=${id}`,
  };
}

describe('filterVideosByCategory', () => {
  const videos = [video('a', 'tech'), video('b', 'music'), video('c', 'tech'), video('d', 'news')];

  it('keeps only the matching category', () => {
    const result = filterVideosByCategory(videos, 'tech');
    expect(result.map((v) => v.id)).toEqual(['a', 'c']);
  });

  it('is case-insensitive', () => {
    const result = filterVideosByCategory(videos, 'TECH');
    expect(result.map((v) => v.id)).toEqual(['a', 'c']);
  });

  it('returns the full list when category is null/undefined', () => {
    expect(filterVideosByCategory(videos, null)).toHaveLength(4);
    expect(filterVideosByCategory(videos, undefined)).toHaveLength(4);
  });

  it('returns an empty list for an unknown category', () => {
    expect(filterVideosByCategory(videos, 'sports')).toEqual([]);
  });
});
