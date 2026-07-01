import { availableLabels, filterVideos } from '../filter';
import { ALL_FILTER, Video } from '../types';

function v(id: string, category: string): Video {
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

const list = [v('1', 'cronicas'), v('2', 'bike'), v('3', 'cronicas'), v('4', 'mnt')];

describe('filterVideos', () => {
  it('keeps only the requested channel label', () => {
    expect(filterVideos(list, 'cronicas').map((x) => x.id)).toEqual(['1', '3']);
  });

  it('is case-insensitive', () => {
    expect(filterVideos(list, 'CRONICAS')).toHaveLength(2);
  });

  it('ALL_FILTER returns everything', () => {
    expect(filterVideos(list, ALL_FILTER)).toHaveLength(4);
  });

  it('availableLabels returns distinct labels in first-appearance order', () => {
    expect(availableLabels(list)).toEqual(['cronicas', 'bike', 'mnt']);
  });
});
