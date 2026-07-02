import { filterByCategory, sortVideos, distinctCategories } from '../src/domain/filterSort';
import { Video } from '../src/domain/types';

function video(overrides: Partial<Video>): Video {
  return {
    id: 'id',
    title: 'title',
    description: 'desc',
    publishedAt: '2026-01-01T00:00:00Z',
    category: 'tech',
    thumbnailUrl: '',
    location: null,
    youtubeUrl: 'https://www.youtube.com/watch?v=id',
    ...overrides,
  };
}

const videos: Video[] = [
  video({ id: '1', title: 'AAA Oldest Clip', category: 'news', publishedAt: '2025-12-01T10:00:00Z' }),
  video({ id: '2', title: 'Tech Talk One', category: 'tech', publishedAt: '2026-03-01T10:00:00Z' }),
  video({ id: '3', title: 'ZZZ Newest Clip', category: 'music', publishedAt: '2026-06-20T10:00:00Z' }),
];

describe('filterByCategory', () => {
  it('returns all videos when category is null', () => {
    expect(filterByCategory(videos, null)).toHaveLength(3);
  });

  it('filters to the matching category, case-insensitively', () => {
    expect(filterByCategory(videos, 'TECH')).toEqual([videos[1]]);
  });

  it('returns an empty list when nothing matches', () => {
    expect(filterByCategory(videos, 'sports')).toEqual([]);
  });
});

describe('sortVideos', () => {
  it('sorts by date descending, newest first', () => {
    const sorted = sortVideos(videos, 'date', 'desc');
    expect(sorted[0].title).toBe('ZZZ Newest Clip');
    expect(sorted[sorted.length - 1].title).toBe('AAA Oldest Clip');
  });

  it('sorts by date ascending, oldest first', () => {
    const sorted = sortVideos(videos, 'date', 'asc');
    expect(sorted[0].title).toBe('AAA Oldest Clip');
    expect(sorted[sorted.length - 1].title).toBe('ZZZ Newest Clip');
  });

  it('sorts by title', () => {
    const sorted = sortVideos(videos, 'title', 'asc');
    expect(sorted.map((v) => v.title)).toEqual(['AAA Oldest Clip', 'Tech Talk One', 'ZZZ Newest Clip']);
  });

  it('does not mutate the input array', () => {
    const copy = [...videos];
    sortVideos(videos, 'date', 'desc');
    expect(videos).toEqual(copy);
  });
});

describe('distinctCategories', () => {
  it('returns unique categories in first-seen order', () => {
    expect(distinctCategories(videos)).toEqual(['news', 'tech', 'music']);
  });
});
