import { sortVideos } from '../sort';
import { Video } from '../types';

function v(id: string, title: string, publishedAt: string): Video {
  return {
    id,
    title,
    description: '',
    publishedAt,
    category: 'x',
    thumbnailUrl: '',
    location: null,
    youtubeUrl: `https://www.youtube.com/watch?v=${id}`,
  };
}

const list: Video[] = [
  v('b', 'Middle', '2026-02-01T10:00:00Z'),
  v('c', 'ZZZ Newest Clip', '2026-06-20T10:00:00Z'),
  v('a', 'AAA Oldest Clip', '2025-12-01T10:00:00Z'),
];

describe('sortVideos', () => {
  it('date_desc puts newest first', () => {
    expect(sortVideos(list, 'date_desc')[0].title).toBe('ZZZ Newest Clip');
  });

  it('date_asc puts oldest first', () => {
    expect(sortVideos(list, 'date_asc')[0].title).toBe('AAA Oldest Clip');
  });

  it('title_asc / title_desc order alphabetically', () => {
    expect(sortVideos(list, 'title_asc')[0].title).toBe('AAA Oldest Clip');
    expect(sortVideos(list, 'title_desc')[0].title).toBe('ZZZ Newest Clip');
  });

  it('does not mutate the input array', () => {
    const before = list.map((x) => x.id);
    sortVideos(list, 'date_desc');
    expect(list.map((x) => x.id)).toEqual(before);
  });
});
