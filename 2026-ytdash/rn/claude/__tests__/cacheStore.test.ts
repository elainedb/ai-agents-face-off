jest.mock('@react-native-async-storage/async-storage', () => {
  let store: Record<string, string> = {};
  return {
    __esModule: true,
    default: {
      getItem: jest.fn((key: string) => Promise.resolve(store[key] ?? null)),
      setItem: jest.fn((key: string, value: string) => {
        store[key] = value;
        return Promise.resolve();
      }),
      removeItem: jest.fn((key: string) => {
        delete store[key];
        return Promise.resolve();
      }),
      __reset: () => {
        store = {};
      },
    },
  };
});

import AsyncStorage from '@react-native-async-storage/async-storage';
import { AsyncStorageCacheStore } from '../src/data/cacheStore';
import { Video } from '../src/domain/types';

const video: Video = {
  id: 'v1',
  title: 'Tech Talk One',
  description: 'desc',
  publishedAt: '2026-03-01T10:00:00Z',
  category: 'tech',
  thumbnailUrl: '',
  location: null,
  youtubeUrl: 'https://www.youtube.com/watch?v=v1',
};

type ResettableAsyncStorage = typeof AsyncStorage & { __reset: () => void };

afterEach(() => {
  (AsyncStorage as ResettableAsyncStorage).__reset();
});

describe('AsyncStorageCacheStore', () => {
  it('returns null when nothing has been cached', async () => {
    const store = new AsyncStorageCacheStore();
    expect(await store.read()).toBeNull();
  });

  it('round-trips a written video list', async () => {
    const store = new AsyncStorageCacheStore();
    await store.write([video], 1234);
    const result = await store.read();
    expect(result).not.toBeNull();
    expect(result!.videos).toEqual([video]);
    expect(result!.fetchedAt).toBe(1234);
  });

  it('replaces the previous cache on a subsequent write', async () => {
    const store = new AsyncStorageCacheStore();
    await store.write([video], 1);
    await store.write([], 2);
    const result = await store.read();
    expect(result!.videos).toEqual([]);
    expect(result!.fetchedAt).toBe(2);
  });

  it('clears the cache', async () => {
    const store = new AsyncStorageCacheStore();
    await store.write([video], 1);
    await store.clear();
    expect(await store.read()).toBeNull();
  });
});
