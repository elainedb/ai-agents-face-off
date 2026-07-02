import type { Video } from '../src/domain/models';
import { distinctCategories, filterVideos, sortVideos } from '../src/domain/sortFilter';

function video(overrides: Partial<Video>): Video {
  return {
    id: 'id',
    title: 'title',
    description: 'desc',
    publishedAt: '2026-01-01T00:00:00Z',
    category: 'tech',
    thumbnailUrl: '',
    youtubeUrl: '',
    lat: null,
    lng: null,
    ...overrides,
  };
}

const videos: Video[] = [
  video({ id: '1', title: 'AAA Oldest Clip', publishedAt: '2025-12-01T10:00:00Z', category: 'news' }),
  video({ id: '2', title: 'ZZZ Newest Clip', publishedAt: '2026-06-20T10:00:00Z', category: 'music' }),
  video({ id: '3', title: 'Tech Talk One', publishedAt: '2026-03-01T10:00:00Z', category: 'tech' }),
];

describe('sortVideos', () => {
  it('sorts by date descending', () => {
    const sorted = sortVideos(videos, 'date-desc');
    expect(sorted[0].title).toBe('ZZZ Newest Clip');
    expect(sorted[sorted.length - 1].title).toBe('AAA Oldest Clip');
  });

  it('sorts by date ascending', () => {
    const sorted = sortVideos(videos, 'date-asc');
    expect(sorted[0].title).toBe('AAA Oldest Clip');
    expect(sorted[sorted.length - 1].title).toBe('ZZZ Newest Clip');
  });

  it('sorts by title ascending', () => {
    const sorted = sortVideos(videos, 'title-asc');
    expect(sorted.map((v) => v.title)).toEqual(['AAA Oldest Clip', 'Tech Talk One', 'ZZZ Newest Clip']);
  });

  it('does not mutate the input array', () => {
    const copy = [...videos];
    sortVideos(videos, 'date-desc');
    expect(videos).toEqual(copy);
  });
});

describe('filterVideos', () => {
  it('returns all videos when label is null', () => {
    expect(filterVideos(videos, null)).toHaveLength(3);
  });

  it('filters case-insensitively by category', () => {
    expect(filterVideos(videos, 'TECH')).toEqual([videos[2]]);
  });

  it('returns empty array when no match', () => {
    expect(filterVideos(videos, 'sports')).toEqual([]);
  });
});

describe('distinctCategories', () => {
  it('returns sorted unique categories', () => {
    expect(distinctCategories(videos)).toEqual(['music', 'news', 'tech']);
  });
});
