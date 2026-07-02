export type Video = {
  id: string;
  title: string;
  description: string;
  publishedAt: string; // ISO-8601
  category: string; // the source channel's configured label
  thumbnailUrl: string;
  youtubeUrl: string;
  lat: number | null;
  lng: number | null;
};

export type SourceChannel = {
  id: string;
  label: string;
};

export type ViewState = 'loading' | 'content' | 'empty' | 'error';

export type SortKey = 'none' | 'date-desc' | 'date-asc' | 'title-asc';

export type TestConfig = {
  uiTestMode: boolean;
  mockAuthEmail: string | null;
  apiBaseUrl: string | null;
  apiKey: string | null;
  authorizedEmails: string | null;
  captureExternalLinks: boolean;
};
