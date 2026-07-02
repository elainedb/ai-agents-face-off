import { sortVideos } from '../domain/sort';
import { Video } from '../domain/types';

function video(id: string, publishedAt: string): Video {
  return {
    id,
    title: id,
    description: '',
    publishedAt,
    category: 'tech',
    thumbnailUrl: '',
    location: null,
    youtubeUrl: `https://www.youtube.com/watch?v=${id}`,
  };
}

describe('sortVideos', () => {
  const videos = [video('mid', '2026-02-01T00:00:00Z'), video('newest', '2026-06-20T00:00:00Z'), video('oldest', '2025-12-01T00:00:00Z')];

  it('sorts descending by date (newest first)', () => {
    const sorted = sortVideos(videos, 'date', 'desc');
    expect(sorted.map((v) => v.id)).toEqual(['newest', 'mid', 'oldest']);
  });

  it('sorts ascending by date (oldest first)', () => {
    const sorted = sortVideos(videos, 'date', 'asc');
    expect(sorted.map((v) => v.id)).toEqual(['oldest', 'mid', 'newest']);
  });

  it('does not mutate the input array', () => {
    const copy = [...videos];
    sortVideos(videos, 'date', 'desc');
    expect(videos).toEqual(copy);
  });
});
