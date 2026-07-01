import AsyncStorage from '@react-native-async-storage/async-storage';
import { Video, watchUrl } from '../../domain/models';
import { loadVideos, saveVideos, clearVideos } from '../cache';

jest.mock('@react-native-async-storage/async-storage', () =>
  require('@react-native-async-storage/async-storage/jest/async-storage-mock')
);

const sample: Video[] = [
  {
    id: 'VIDEO_ID_1',
    title: 'Tech Talk One',
    description: 'A talk about tech.',
    publishedAt: '2026-03-01T10:00:00Z',
    category: 'tech',
    thumbnailUrl: null,
    location: { lat: 48.8566, lng: 2.3522 },
    youtubeUrl: watchUrl('VIDEO_ID_1'),
  },
];

describe('cache persistence', () => {
  beforeEach(() => AsyncStorage.clear());

  it('returns null when nothing is stored', async () => {
    expect(await loadVideos()).toBeNull();
  });

  it('round-trips a saved list', async () => {
    await saveVideos(sample);
    const loaded = await loadVideos();
    expect(loaded).not.toBeNull();
    expect(loaded).toHaveLength(1);
    expect(loaded![0].id).toBe('VIDEO_ID_1');
    expect(loaded![0].location).toEqual({ lat: 48.8566, lng: 2.3522 });
  });

  it('clears the store', async () => {
    await saveVideos(sample);
    await clearVideos();
    expect(await loadVideos()).toBeNull();
  });
});
