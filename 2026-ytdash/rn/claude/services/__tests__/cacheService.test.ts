import AsyncStorage from '@react-native-async-storage/async-storage';
import {
  saveToCache,
  getFromCache,
  clearCache,
  isCacheValid,
  getCacheAge,
} from '../cacheService';

const mockVideos = [
  {
    id: 'test1',
    title: 'Test Video',
    channelName: 'Test Channel',
    publishedAt: '2024-01-01T00:00:00Z',
    thumbnailUrl: 'https://example.com/thumb.jpg',
    videoUrl: 'https://www.youtube.com/watch?v=test1',
    tags: ['test'],
  },
];

describe('cacheService', () => {
  beforeEach(() => {
    jest.clearAllMocks();
  });

  it('saves videos to cache', async () => {
    await saveToCache(mockVideos as any);
    expect(AsyncStorage.setItem).toHaveBeenCalledWith(
      'youtube_videos_cache',
      expect.any(String)
    );
  });

  it('returns null when cache is empty', async () => {
    (AsyncStorage.getItem as jest.Mock).mockResolvedValue(null);
    const result = await getFromCache();
    expect(result).toBeNull();
  });

  it('returns videos from valid cache', async () => {
    const cacheData = {
      videos: mockVideos,
      timestamp: Date.now(),
    };
    (AsyncStorage.getItem as jest.Mock).mockResolvedValue(
      JSON.stringify(cacheData)
    );
    const result = await getFromCache();
    expect(result).toEqual(mockVideos);
  });

  it('returns null for expired cache', async () => {
    const cacheData = {
      videos: mockVideos,
      timestamp: Date.now() - 25 * 60 * 60 * 1000, // 25 hours ago
    };
    (AsyncStorage.getItem as jest.Mock).mockResolvedValue(
      JSON.stringify(cacheData)
    );
    const result = await getFromCache();
    expect(result).toBeNull();
  });

  it('clears cache', async () => {
    await clearCache();
    expect(AsyncStorage.removeItem).toHaveBeenCalledWith('youtube_videos_cache');
  });

  it('reports cache validity correctly', async () => {
    (AsyncStorage.getItem as jest.Mock).mockResolvedValue(null);
    expect(await isCacheValid()).toBe(false);

    const validCache = {
      videos: mockVideos,
      timestamp: Date.now(),
    };
    (AsyncStorage.getItem as jest.Mock).mockResolvedValue(
      JSON.stringify(validCache)
    );
    expect(await isCacheValid()).toBe(true);
  });

  it('returns cache age in minutes', async () => {
    (AsyncStorage.getItem as jest.Mock).mockResolvedValue(null);
    expect(await getCacheAge()).toBeNull();

    const cacheData = {
      videos: mockVideos,
      timestamp: Date.now() - 30 * 60 * 1000, // 30 minutes ago
    };
    (AsyncStorage.getItem as jest.Mock).mockResolvedValue(
      JSON.stringify(cacheData)
    );
    const age = await getCacheAge();
    expect(age).toBeGreaterThanOrEqual(29);
    expect(age).toBeLessThanOrEqual(31);
  });
});
