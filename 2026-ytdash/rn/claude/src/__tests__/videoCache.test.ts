import AsyncStorage from '@react-native-async-storage/async-storage';

import { clearVideos, loadVideos, saveVideos } from '../data/videoCache';
import { Video } from '../domain/types';

const sample: Video[] = [
  {
    id: 'VIDEO_ID_1',
    title: 'Tech Talk One',
    description: 'A talk about tech.',
    publishedAt: '2026-03-01T10:00:00Z',
    category: 'tech',
    thumbnailUrl: 'https://i.ytimg.com/vi/VIDEO_ID_1/mqdefault.jpg',
    location: { lat: 48.8566, lng: 2.3522 },
    youtubeUrl: 'https://www.youtube.com/watch?v=VIDEO_ID_1',
  },
];

describe('videoCache (AsyncStorage persistence)', () => {
  afterEach(async () => {
    await AsyncStorage.clear();
  });

  it('returns null when nothing has been cached yet', async () => {
    expect(await loadVideos()).toBeNull();
  });

  it('round-trips a saved list byte-for-byte equal', async () => {
    await saveVideos(sample);
    const loaded = await loadVideos();
    expect(loaded).toEqual(sample);
  });

  it('replaces the previous cache on a second save', async () => {
    await saveVideos(sample);
    await saveVideos([]);
    expect(await loadVideos()).toEqual([]);
  });

  it('clearVideos removes the cache', async () => {
    await saveVideos(sample);
    await clearVideos();
    expect(await loadVideos()).toBeNull();
  });
});
