// Domain model — decoupled from the YouTube API wire shapes.
export type GeoLocation = { lat: number; lng: number };

export type Video = {
  id: string;
  title: string;
  description: string;
  publishedAt: string; // ISO-8601, the sort key
  category: string; // the source channel's label
  thumbnailUrl: string | null;
  location: GeoLocation | null;
  youtubeUrl: string;
};

export function watchUrl(videoId: string): string {
  return `https://www.youtube.com/watch?v=${videoId}`;
}
