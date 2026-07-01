import { sortVideos, SORT_OPTIONS } from '../src/domain/sort';
import { Video } from '../src/data/types';

function v(id: string, title: string, publishedAt: string): Video {
  return {
    id,
    title,
    description: '',
    publishedAt,
    category: 'x',
    thumbnailUrl: null,
    lat: null,
    lng: null,
    youtubeUrl: `https://www.youtube.com/watch?v=${id}`,
  };
}

const videos: Video[] = [
  v('a', 'Tech Talk One', '2026-03-01T10:00:00Z'),
  v('z', 'ZZZ Newest Clip', '2026-06-20T10:00:00Z'),
  v('o', 'AAA Oldest Clip', '2025-12-01T10:00:00Z'),
];

describe('sortVideos', () => {
  it('date desc puts newest first', () => {
    const r = sortVideos(videos, { key: 'date', dir: 'desc' });
    expect(r[0].title).toBe('ZZZ Newest Clip');
  });

  it('date asc puts oldest first', () => {
    const r = sortVideos(videos, { key: 'date', dir: 'asc' });
    expect(r[0].title).toBe('AAA Oldest Clip');
  });

  it('title asc is alphabetical', () => {
    const r = sortVideos(videos, { key: 'title', dir: 'asc' });
    expect(r.map((x) => x.title)).toEqual(['AAA Oldest Clip', 'Tech Talk One', 'ZZZ Newest Clip']);
  });

  it('title desc is reverse alphabetical', () => {
    const r = sortVideos(videos, { key: 'title', dir: 'desc' });
    expect(r[0].title).toBe('ZZZ Newest Clip');
  });

  it('does not mutate the input', () => {
    const copy = [...videos];
    sortVideos(videos, { key: 'date', dir: 'desc' });
    expect(videos).toEqual(copy);
  });

  it('the date-desc option label matches the Maestro sort regex', () => {
    const label = SORT_OPTIONS.find((o) => o.option.key === 'date' && o.option.dir === 'desc')!.label;
    expect(new RegExp('(?i)date.*(desc|newest)'.replace('(?i)', ''), 'i').test(label)).toBe(true);
  });
});
