import { loadTestConfig } from './testConfig';
import { CHANNELS } from '../config/channels';
import { ApiConfig } from '../data/api';

// Production defaults. The email whitelist is app policy (not a credential); the API key IS a
// secret and is injected at build time via an EXPO_PUBLIC_ env var — never committed to source.
const PROD_WHITELIST = ['user1@example.com', 'user2@example.com'];
const PROD_API_BASE = 'https://www.googleapis.com';
const PROD_API_KEY = process.env.EXPO_PUBLIC_YOUTUBE_API_KEY ?? '';

export type AppConfig = {
  uiTestMode: boolean;
  mockAuthEmail: string | null;
  captureExternalLinks: boolean;
  whitelist: string[];
  api: ApiConfig;
};

let cached: AppConfig | null = null;

/** Compose runtime config: launch extras (UI-test-mode) override production defaults. */
export function getAppConfig(): AppConfig {
  if (cached) return cached;
  const tc = loadTestConfig();
  cached = {
    uiTestMode: tc.uiTestMode,
    mockAuthEmail: tc.mockAuthEmail,
    captureExternalLinks: tc.captureExternalLinks,
    whitelist: tc.authorizedEmails ?? PROD_WHITELIST,
    api: {
      baseUrl: tc.apiBaseUrl ?? PROD_API_BASE,
      apiKey: tc.apiKey ?? PROD_API_KEY,
      channels: CHANNELS,
    },
  };
  return cached;
}

export function __resetAppConfig() {
  cached = null;
}
