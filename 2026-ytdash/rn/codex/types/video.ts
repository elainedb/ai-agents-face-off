export type VideoLocation = {
  city?: string;
  country?: string;
  latitude?: number;
  longitude?: number;
};

export type VideoData = {
  id: string;
  title: string;
  channelName: string;
  publishedAt: string;
  thumbnailUrl: string;
  videoUrl: string;
  tags: string[];
  location?: VideoLocation;
  recordingDate?: string;
};

export type Filters = {
  channelName: string;
  country: string;
};

export type SortOptions = {
  field: 'publishedAt' | 'recordingDate';
  order: 'asc' | 'desc';
};
