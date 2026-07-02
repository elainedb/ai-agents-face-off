import Constants from 'expo-constants';

import TestConfigModule from '../../modules/test-config';

export type ResolvedConfig = {
  uiTestMode: boolean;
  mockAuthEmail: string | null;
  apiBaseUrl: string;
  apiKey: string;
  authorizedEmails: string[];
  captureExternalLinks: boolean;
};

const REAL_YOUTUBE_BASE_URL = 'https://www.googleapis.com';

function parseEmailList(csv: string | null | undefined): string[] {
  if (!csv) return [];
  return csv
    .split(',')
    .map((e) => e.trim())
    .filter(Boolean);
}

// Resolves the app's runtime configuration once at boot. UI-test-mode launch-intent extras
// (constitution.md §4), when present, override every production default — this is the single
// seam that lets the same build run against the mock or the real API without a rebuild.
export function resolveTestConfig(): ResolvedConfig {
  const extra = (Constants.expoConfig?.extra ?? {}) as {
    youtubeApiKey?: string;
    authorizedEmails?: string;
  };

  let raw: ReturnType<typeof TestConfigModule.get> | null = null;
  try {
    raw = TestConfigModule.get();
  } catch {
    // Native module unavailable (e.g. Expo Go, or web) — fall back to production behavior.
    raw = null;
  }

  const uiTestMode = raw?.uiTestMode ?? false;

  if (uiTestMode) {
    return {
      uiTestMode: true,
      mockAuthEmail: raw?.mockAuthEmail ?? null,
      apiBaseUrl: raw?.apiBaseUrl || REAL_YOUTUBE_BASE_URL,
      apiKey: raw?.apiKey || extra.youtubeApiKey || '',
      authorizedEmails: parseEmailList(raw?.authorizedEmails ?? extra.authorizedEmails),
      captureExternalLinks: raw?.captureExternalLinks ?? false,
    };
  }

  return {
    uiTestMode: false,
    mockAuthEmail: null,
    apiBaseUrl: REAL_YOUTUBE_BASE_URL,
    apiKey: extra.youtubeApiKey || '',
    authorizedEmails: parseEmailList(extra.authorizedEmails),
    captureExternalLinks: false,
  };
}
