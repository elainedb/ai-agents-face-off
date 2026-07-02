const store = new Map<string, string>();

jest.mock('@react-native-async-storage/async-storage', () => ({
  getItem: jest.fn((key: string) => Promise.resolve(store.get(key) ?? null)),
  setItem: jest.fn((key: string, value: string) => {
    store.set(key, value);
    return Promise.resolve();
  }),
}));

import type { Video } from '../src/domain/models';
import { readCache, writeCache } from '../src/data/cache';

const sample: Video[] = [
  {
    id: 'VIDEO_ID_1',
    title: 'Tech Talk One',
    description: 'A talk about tech.',
    publishedAt: '2026-03-01T10:00:00Z',
    category: 'tech',
    thumbnailUrl: 'https://example.com/thumb.jpg',
    youtubeUrl: 'https://www.youtube.com/watch?v=VIDEO_ID_1',
    lat: 48.8566,
    lng: 2.3522,
  },
];

describe('cache read/write (persistence)', () => {
  beforeEach(() => {
    store.clear();
  });

  it('returns null when nothing has been cached', async () => {
    expect(await readCache()).toBeNull();
  });

  it('round-trips a written video list', async () => {
    await writeCache(sample);
    const read = await readCache();
    expect(read).toEqual(sample);
  });

  it('overwrites the previous cache on a second write (replace-on-refresh)', async () => {
    await writeCache(sample);
    const second = [...sample, { ...sample[0], id: 'VIDEO_ID_2', title: 'Tech Talk Two' }];
    await writeCache(second);
    const read = await readCache();
    expect(read).toHaveLength(2);
    expect(read?.map((v) => v.id)).toEqual(['VIDEO_ID_1', 'VIDEO_ID_2']);
  });
});
