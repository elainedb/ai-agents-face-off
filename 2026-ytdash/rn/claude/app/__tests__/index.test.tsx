import { fetchAllVideos, enhanceLocationData, type VideoData } from '@/services/youtubeApi';
import AsyncStorage from '@react-native-async-storage/async-storage';
import * as cacheService from '@/services/cacheService';

describe('YouTube API Service', () => {
  it('should export fetchAllVideos function', () => {
    expect(typeof fetchAllVideos).toBe('function');
  });

  it('should export enhanceLocationData function', () => {
    expect(typeof enhanceLocationData).toBe('function');
  });
});

describe('Cache Service', () => {
  beforeEach(() => {
    jest.clearAllMocks();
  });

  it('should return null from cache when empty', async () => {
    (AsyncStorage.getItem as jest.Mock).mockResolvedValue(null);
    const result = await cacheService.getFromCache();
    expect(result).toBeNull();
  });

  it('should save to cache', async () => {
    const videos: VideoData[] = [];
    await cacheService.saveToCache(videos);
    expect(AsyncStorage.setItem).toHaveBeenCalledWith(
      'youtube_videos_cache',
      expect.any(String)
    );
  });

  it('should clear cache', async () => {
    await cacheService.clearCache();
    expect(AsyncStorage.removeItem).toHaveBeenCalledWith('youtube_videos_cache');
  });

  it('should return false for isCacheValid when empty', async () => {
    (AsyncStorage.getItem as jest.Mock).mockResolvedValue(null);
    const valid = await cacheService.isCacheValid();
    expect(valid).toBe(false);
  });

  it('should return -1 for getCacheAge when empty', async () => {
    (AsyncStorage.getItem as jest.Mock).mockResolvedValue(null);
    const age = await cacheService.getCacheAge();
    expect(age).toBe(-1);
  });

  it('should return cached videos when valid', async () => {
    const mockCache = {
      videos: [{ id: '1', title: 'Test', channelName: 'Test', publishedAt: '2024-01-01', thumbnailUrl: '', videoUrl: '', tags: [] }],
      timestamp: Date.now(),
    };
    (AsyncStorage.getItem as jest.Mock).mockResolvedValue(JSON.stringify(mockCache));
    const result = await cacheService.getFromCache();
    expect(result).toHaveLength(1);
    expect(result![0].id).toBe('1');
  });

  it('should return null for expired cache', async () => {
    const mockCache = {
      videos: [{ id: '1', title: 'Test' }],
      timestamp: Date.now() - 25 * 60 * 60 * 1000, // 25 hours ago
    };
    (AsyncStorage.getItem as jest.Mock).mockResolvedValue(JSON.stringify(mockCache));
    const result = await cacheService.getFromCache();
    expect(result).toBeNull();
  });
});
