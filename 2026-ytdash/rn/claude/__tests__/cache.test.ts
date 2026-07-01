import { saveVideos, loadVideos, clearVideos } from '../src/data/cache';
import { Video } from '../src/data/types';

function v(id: string): Video {
  return {
    id,
    title: `Video ${id}`,
    description: '',
    publishedAt: '2026-01-01T00:00:00Z',
    category: 'x',
    thumbnailUrl: null,
    lat: null,
    lng: null,
    youtubeUrl: `https://www.youtube.com/watch?v=${id}`,
  };
}

describe('cache round-trip (persistence)', () => {
  beforeEach(async () => {
    await clearVideos();
  });

  it('returns null when nothing is cached', async () => {
    expect(await loadVideos()).toBeNull();
  });

  it('saves and loads the same videos, marked fresh', async () => {
    const videos = [v('1'), v('2'), v('3')];
    const res = await saveVideos(videos);
    expect(res.ok).toBe(true);

    const loaded = await loadVideos();
    expect(loaded).not.toBeNull();
    expect(loaded!.videos).toHaveLength(3);
    expect(loaded!.videos.map((x) => x.id)).toEqual(['1', '2', '3']);
    expect(loaded!.fresh).toBe(true);
  });

  it('replace-on-refresh overwrites the previous snapshot', async () => {
    await saveVideos([v('1'), v('2')]);
    await saveVideos([v('9')]);
    const loaded = await loadVideos();
    expect(loaded!.videos.map((x) => x.id)).toEqual(['9']);
  });
});
