import { getNativeTestConfig } from '../../modules/test-config';
import { AppConfig } from '../domain/types';

// Production defaults. The API base URL is overridable (constitution §2) — never hardcode the prod
// host as the only option. The key is read at RUNTIME from the launch extra (constitution §4) so the
// same build talks to the mock or the real API by swapping extras.
const DEFAULTS = {
  apiBaseUrl: 'https://www.googleapis.com',
  apiKey: '',
  // Real-mode whitelist (overridden per-run by the `authorizedEmails` extra).
  authorizedEmails: ['user1@example.com', 'user2@example.com'],
};

function parseEmails(csv: string | null | undefined): string[] {
  if (!csv) return [];
  return csv
    .split(',')
    .map((e) => e.trim())
    .filter(Boolean);
}

// Assemble the effective runtime config from the native launch extras merged with defaults.
export function loadAppConfig(): AppConfig {
  const native = getNativeTestConfig();
  const overrideEmails = parseEmails(native.authorizedEmails);
  return {
    uiTestMode: !!native.uiTestMode,
    mockAuthEmail: native.mockAuthEmail ?? null,
    apiBaseUrl: (native.apiBaseUrl && native.apiBaseUrl.trim()) || DEFAULTS.apiBaseUrl,
    apiKey: (native.apiKey && native.apiKey.trim()) || DEFAULTS.apiKey,
    authorizedEmails: overrideEmails.length ? overrideEmails : DEFAULTS.authorizedEmails,
    captureExternalLinks: !!native.captureExternalLinks,
  };
}
