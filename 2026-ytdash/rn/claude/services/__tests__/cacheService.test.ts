import AsyncStorage from '@react-native-async-storage/async-storage';
import {
  saveToCache,
  getFromCache,
  clearCache,
  isCacheValid,
  getCacheAge,
} from '../cacheService';
import type { VideoData } from '../youtubeApi';

const mockVideos: VideoData[] = [
  {
    id: 'video1',
    title: 'Test Video',
    channelName: 'Test Channel',
    publishedAt: '2024-01-01T00:00:00Z',
    thumbnailUrl: 'https://example.com/thumb.jpg',
    videoUrl: 'https://www.youtube.com/watch?v=video1',
    tags: ['test'],
  },
];

describe('cacheService', () => {
  beforeEach(() => {
    jest.clearAllMocks();
  });

  describe('saveToCache', () => {
    it('should save videos to AsyncStorage', async () => {
      await saveToCache(mockVideos);
      expect(AsyncStorage.setItem).toHaveBeenCalledWith(
        'youtube_videos_cache',
        expect.any(String)
      );
      const savedData = JSON.parse(
        (AsyncStorage.setItem as jest.Mock).mock.calls[0][1]
      );
      expect(savedData.videos).toEqual(mockVideos);
      expect(savedData.timestamp).toBeDefined();
    });
  });

  describe('getFromCache', () => {
    it('should return null if no cache exists', async () => {
      (AsyncStorage.getItem as jest.Mock).mockResolvedValue(null);
      const result = await getFromCache();
      expect(result).toBeNull();
    });

    it('should return videos if cache is valid', async () => {
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

    it('should return null if cache is expired', async () => {
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
  });

  describe('clearCache', () => {
    it('should remove cache from AsyncStorage', async () => {
      await clearCache();
      expect(AsyncStorage.removeItem).toHaveBeenCalledWith(
        'youtube_videos_cache'
      );
    });
  });

  describe('isCacheValid', () => {
    it('should return false if no cache exists', async () => {
      (AsyncStorage.getItem as jest.Mock).mockResolvedValue(null);
      const result = await isCacheValid();
      expect(result).toBe(false);
    });

    it('should return true if cache is not expired', async () => {
      const cacheData = {
        videos: mockVideos,
        timestamp: Date.now(),
      };
      (AsyncStorage.getItem as jest.Mock).mockResolvedValue(
        JSON.stringify(cacheData)
      );
      const result = await isCacheValid();
      expect(result).toBe(true);
    });
  });

  describe('getCacheAge', () => {
    it('should return null if no cache exists', async () => {
      (AsyncStorage.getItem as jest.Mock).mockResolvedValue(null);
      const result = await getCacheAge();
      expect(result).toBeNull();
    });

    it('should return age in minutes', async () => {
      const tenMinutesAgo = Date.now() - 10 * 60 * 1000;
      const cacheData = {
        videos: mockVideos,
        timestamp: tenMinutesAgo,
      };
      (AsyncStorage.getItem as jest.Mock).mockResolvedValue(
        JSON.stringify(cacheData)
      );
      const result = await getCacheAge();
      expect(result).toBeGreaterThanOrEqual(9);
      expect(result).toBeLessThanOrEqual(11);
    });
  });
});
