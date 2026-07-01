import { fetchAllVideos } from '../src/data/api';

// A tiny in-test mock that mirrors the real YouTube shapes with SMALL pages, so this exercises
// pagination + multi-channel aggregation + dedupe + location enrichment — the anti-overfit path.
const CHANNEL_VIDEOS: Record<string, string[]> = {
  c1: ['v1', 'v2', 'v3'], // 3 videos → 2 pages at pageSize 2
  c2: ['v3', 'v4'], // note v3 duplicated across channels → must dedupe
};
const LOCATED = new Set(['v1', 'v4']);
const PAGE = 2;

function searchPage(channelId: string, token: string) {
  const ids = CHANNEL_VIDEOS[channelId] ?? [];
  const offset = token ? parseInt(token, 10) : 0;
  const slice = ids.slice(offset, offset + PAGE);
  const next = offset + PAGE;
  return {
    items: slice.map((id) => ({
      id: { videoId: id },
      snippet: { title: `Title ${id}`, description: 'd', publishedAt: '2026-01-01T00:00:00Z', thumbnails: {} },
    })),
    ...(next < ids.length ? { nextPageToken: String(next) } : {}),
  };
}

function videosResponse(ids: string[]) {
  return {
    items: ids.map((id) => ({
      id,
      snippet: { title: `Title ${id}` },
      ...(LOCATED.has(id) ? { recordingDetails: { location: { latitude: 1.5, longitude: 2.5 } } } : {}),
    })),
  };
}

beforeEach(() => {
  (global as any).fetch = jest.fn(async (url: string) => {
    const u = new URL(url);
    const q = u.searchParams;
    if (u.pathname.endsWith('/search')) {
      return { ok: true, json: async () => searchPage(q.get('channelId') || '', q.get('pageToken') || '') } as any;
    }
    if (u.pathname.endsWith('/videos')) {
      const ids = (q.get('id') || '').split(',').filter(Boolean);
      return { ok: true, json: async () => videosResponse(ids) } as any;
    }
    return { ok: false, status: 404, json: async () => ({}) } as any;
  });
});

describe('fetchAllVideos (aggregate + paginate + dedupe + enrich)', () => {
  const config = {
    baseUrl: 'http://mock.local',
    apiKey: 'k',
    channels: [
      { id: 'c1', label: 'alpha' },
      { id: 'c2', label: 'beta' },
    ],
  };

  it('follows pagination and aggregates all channels, deduped by videoId', async () => {
    const res = await fetchAllVideos(config);
    expect(res.ok).toBe(true);
    if (!res.ok) return;
    const ids = res.value.map((v) => v.id);
    // v1,v2,v3 from c1 (2 pages) + v4 from c2 (v3 deduped) = 4 unique
    expect(ids.sort()).toEqual(['v1', 'v2', 'v3', 'v4']);
  });

  it('tags category with the source channel label of first appearance', async () => {
    const res = await fetchAllVideos(config);
    if (!res.ok) throw new Error('expected ok');
    expect(res.value.find((v) => v.id === 'v1')!.category).toBe('alpha');
    expect(res.value.find((v) => v.id === 'v4')!.category).toBe('beta');
    expect(res.value.find((v) => v.id === 'v3')!.category).toBe('alpha'); // dedupe keeps first
  });

  it('enriches only located videos and builds the watch URL', async () => {
    const res = await fetchAllVideos(config);
    if (!res.ok) throw new Error('expected ok');
    const located = res.value.filter((v) => v.lat != null);
    expect(located.map((v) => v.id).sort()).toEqual(['v1', 'v4']);
    expect(res.value[0].youtubeUrl).toBe('https://www.youtube.com/watch?v=v1');
  });

  it('returns a network error result when fetch fails', async () => {
    (global as any).fetch = jest.fn(async () => ({ ok: false, status: 500, json: async () => ({}) }));
    const res = await fetchAllVideos(config);
    expect(res.ok).toBe(false);
  });
});
