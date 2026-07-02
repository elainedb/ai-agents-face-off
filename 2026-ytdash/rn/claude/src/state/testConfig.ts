import TestConfigModule from '../../modules/test-config/src';
import { TestConfig } from '../../modules/test-config/src/TestConfig.types';

// Real-mode defaults used when no launch-intent extras override them (production installs, or a
// manual `expo run:android` without Maestro). These are NOT secrets: the API key still comes from
// the `apiKey` extra / EXPO_PUBLIC_YOUTUBE_API_KEY at runtime, never hardcoded here.
const DEFAULT_REAL_API_BASE = 'https://www.googleapis.com';
const DEFAULT_AUTHORIZED_EMAILS = 'user1@example.com,user2@example.com';

export type ResolvedConfig = {
  uiTestMode: boolean;
  mockAuthEmail: string | null;
  apiBaseUrl: string;
  apiKey: string;
  authorizedEmails: string;
  captureExternalLinks: boolean;
};

let cached: ResolvedConfig | null = null;

function readNative(): TestConfig {
  try {
    return TestConfigModule.getConfig();
  } catch {
    // Native module unavailable (e.g. web preview) — behave as production, no test overrides.
    return {
      uiTestMode: false,
      mockAuthEmail: null,
      apiBaseUrl: null,
      apiKey: null,
      authorizedEmails: null,
      captureExternalLinks: false,
    };
  }
}

/** Read once at boot, before the first render, so the whole app sees a stable config. */
export function loadTestConfig(): ResolvedConfig {
  if (cached) return cached;
  const native = readNative();
  cached = {
    uiTestMode: native.uiTestMode,
    mockAuthEmail: native.mockAuthEmail,
    apiBaseUrl: native.apiBaseUrl || DEFAULT_REAL_API_BASE,
    apiKey: native.apiKey || process.env.EXPO_PUBLIC_YOUTUBE_API_KEY || '',
    authorizedEmails: native.authorizedEmails || DEFAULT_AUTHORIZED_EMAILS,
    captureExternalLinks: native.captureExternalLinks,
  };
  return cached;
}

export function getTestConfig(): ResolvedConfig {
  return cached ?? loadTestConfig();
}
