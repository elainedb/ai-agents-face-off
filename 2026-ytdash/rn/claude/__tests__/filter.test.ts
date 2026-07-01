import { filterVideos, availableCategories } from '../src/domain/filter';
import { Video } from '../src/data/types';

function v(id: string, title: string, category: string): Video {
  return {
    id,
    title,
    description: '',
    publishedAt: '2026-01-01T00:00:00Z',
    category,
    thumbnailUrl: null,
    lat: null,
    lng: null,
    youtubeUrl: `https://www.youtube.com/watch?v=${id}`,
  };
}

const videos: Video[] = [
  v('1', 'Tech Talk One', 'cronicas'),
  v('2', 'Tech Talk Two', 'cronicas'),
  v('8', 'ZZZ Newest Clip', 'bike'),
  v('5', 'News Roundup', 'mnt'),
];

describe('filterVideos', () => {
  it('keeps only the chosen category label', () => {
    const r = filterVideos(videos, 'cronicas');
    expect(r.map((x) => x.title)).toEqual(['Tech Talk One', 'Tech Talk Two']);
    expect(r.some((x) => x.title === 'ZZZ Newest Clip')).toBe(false);
  });

  it('is case-insensitive', () => {
    expect(filterVideos(videos, 'CRONICAS')).toHaveLength(2);
  });

  it('null category returns all', () => {
    expect(filterVideos(videos, null)).toHaveLength(4);
  });
});

describe('availableCategories', () => {
  it('returns distinct labels in first-appearance order', () => {
    expect(availableCategories(videos)).toEqual(['cronicas', 'bike', 'mnt']);
  });
});
