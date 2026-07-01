import { getTestConfig } from '../modules/test-config';

// Resolved, framework-neutral runtime configuration. UI-test-mode extras (constitution §4) win;
// otherwise we fall back to production defaults. The API base URL is ALWAYS overridable so the
// same build talks to the mock or to real YouTube by swapping two launch extras — nothing about
// the host is hard-coded (constitution §2).
export type AppConfig = {
  uiTestMode: boolean;
  mockAuthEmail: string | null;
  apiBaseUrl: string;
  apiKey: string;
  authorizedEmails: string[];
  captureExternalLinks: boolean;
};

// Production defaults (non-secret). The real API key is supplied at runtime via the `apiKey`
// launch extra (or a build-time secret), never committed.
const DEFAULT_API_BASE = 'https://www.googleapis.com';
const DEFAULT_AUTHORIZED = ['user1@example.com', 'user2@example.com'];

function parseEmails(csv: string | null): string[] {
  if (!csv) return [];
  return csv
    .split(',')
    .map((e) => e.trim().toLowerCase())
    .filter(Boolean);
}

let cached: AppConfig | null = null;

export function resolveConfig(): AppConfig {
  if (cached) return cached;
  const raw = getTestConfig();
  const authorized = parseEmails(raw.authorizedEmails);
  cached = {
    uiTestMode: raw.uiTestMode,
    mockAuthEmail: raw.mockAuthEmail,
    apiBaseUrl: (raw.apiBaseUrl && raw.apiBaseUrl.trim()) || DEFAULT_API_BASE,
    apiKey: (raw.apiKey && raw.apiKey.trim()) || '',
    authorizedEmails: authorized.length ? authorized : DEFAULT_AUTHORIZED,
    captureExternalLinks: raw.captureExternalLinks,
  };
  return cached;
}
