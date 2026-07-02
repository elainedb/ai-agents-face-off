export type VideoLocation = {
  lat: number;
  lng: number;
};

export type Video = {
  id: string;
  title: string;
  description: string;
  publishedAt: string;
  category: string;
  thumbnailUrl: string;
  location: VideoLocation | null;
  youtubeUrl: string;
};

export type SourceChannel = {
  id: string;
  label: string;
};

export type SortKey = 'date' | 'title';
export type SortDirection = 'asc' | 'desc';

export type VideoListStatus = 'loading' | 'content' | 'empty' | 'error';
