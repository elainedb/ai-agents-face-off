import { clearVideos, loadVideos, saveVideos } from '../cache';
import { Video } from '../../domain/types';

jest.mock('@react-native-async-storage/async-storage', () =>
  require('@react-native-async-storage/async-storage/jest/async-storage-mock')
);

const sample: Video[] = [
  {
    id: 'VIDEO_ID_1',
    title: 'Tech Talk One',
    description: 'A talk about tech.',
    publishedAt: '2026-03-01T10:00:00Z',
    category: 'cronicas',
    thumbnailUrl: 'https://example/t.jpg',
    location: { lat: 48.8566, lng: 2.3522 },
    youtubeUrl: 'https://www.youtube.com/watch?v=VIDEO_ID_1',
  },
];

describe('cache round-trip (persistence)', () => {
  beforeEach(async () => {
    await clearVideos();
  });

  it('saves and loads the same list', async () => {
    await saveVideos(sample);
    const loaded = await loadVideos();
    expect(loaded).not.toBeNull();
    expect(loaded!.videos).toEqual(sample);
    expect(loaded!.stale).toBe(false);
  });

  it('returns null when nothing is cached', async () => {
    expect(await loadVideos()).toBeNull();
  });
});
