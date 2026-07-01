import { isAuthorized } from '../auth';
import { availableCategories, filterByCategory } from '../filter';
import { Video, watchUrl } from '../models';
import { sortVideos } from '../sort';

const mk = (id: string, title: string, publishedAt: string, category: string): Video => ({
  id,
  title,
  description: '',
  publishedAt,
  category,
  thumbnailUrl: null,
  location: null,
  youtubeUrl: watchUrl(id),
});

const videos: Video[] = [
  mk('1', 'Tech Talk One', '2026-03-01T10:00:00Z', 'tech'),
  mk('4', 'Music Session', '2026-04-01T10:00:00Z', 'music'),
  mk('7', 'AAA Oldest Clip', '2025-12-01T10:00:00Z', 'news'),
  mk('8', 'ZZZ Newest Clip', '2026-06-20T10:00:00Z', 'music'),
];

describe('auth whitelist', () => {
  const wl = ['User1@example.com', 'user2@example.com'];
  it('accepts a whitelisted email case-insensitively', () => {
    expect(isAuthorized('user2@example.com', wl)).toBe(true);
    expect(isAuthorized('  USER2@example.com ', wl)).toBe(true);
  });
  it('rejects a non-whitelisted email', () => {
    expect(isAuthorized('intruder@gmail.com', wl)).toBe(false);
  });
  it('rejects empty / null', () => {
    expect(isAuthorized('', wl)).toBe(false);
    expect(isAuthorized(null, wl)).toBe(false);
  });
});

describe('sort', () => {
  it('date-desc puts the newest first', () => {
    expect(sortVideos(videos, 'date-desc')[0].title).toBe('ZZZ Newest Clip');
  });
  it('date-asc puts the oldest first', () => {
    expect(sortVideos(videos, 'date-asc')[0].title).toBe('AAA Oldest Clip');
  });
  it('title-asc sorts alphabetically', () => {
    expect(sortVideos(videos, 'title-asc')[0].title).toBe('AAA Oldest Clip');
  });
  it('does not mutate the input', () => {
    const before = videos.map((v) => v.id);
    sortVideos(videos, 'date-desc');
    expect(videos.map((v) => v.id)).toEqual(before);
  });
});

describe('filter', () => {
  it('keeps only the chosen category', () => {
    const out = filterByCategory(videos, 'music');
    expect(out.map((v) => v.title).sort()).toEqual(['Music Session', 'ZZZ Newest Clip']);
    expect(out.find((v) => v.title === 'Tech Talk One')).toBeUndefined();
  });
  it('null filter returns everything', () => {
    expect(filterByCategory(videos, null)).toHaveLength(4);
  });
  it('lists available categories in first-appearance order', () => {
    expect(availableCategories(videos)).toEqual(['tech', 'music', 'news']);
  });
});
