// Domain model — framework-neutral, no API/JSON shapes leak in here.

export type GeoLocation = {
  lat: number;
  lng: number;
};

export type Video = {
  id: string;
  title: string;
  description: string;
  publishedAt: string; // ISO-8601
  category: string; // the SOURCE CHANNEL's configured label (spec: "category" = channel label)
  thumbnailUrl: string;
  location: GeoLocation | null;
  youtubeUrl: string; // https://www.youtube.com/watch?v=<id>
};

export type SourceChannel = {
  id: string;
  label: string;
};

// Runtime configuration, assembled from UI-test-mode launch extras (constitution §4) + defaults.
export type AppConfig = {
  uiTestMode: boolean;
  mockAuthEmail: string | null;
  apiBaseUrl: string; // host root, no /youtube/v3 suffix
  apiKey: string;
  authorizedEmails: string[];
  captureExternalLinks: boolean;
};

// Observable, unidirectional view-state (constitution §1.3).
export type UiStatus = 'idle' | 'loading' | 'content' | 'empty' | 'error';

export type SortKey = 'date_desc' | 'date_asc' | 'title_asc' | 'title_desc';

export const ALL_FILTER = '__all__';
