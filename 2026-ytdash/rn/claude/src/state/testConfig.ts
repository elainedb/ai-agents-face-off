import { getRawExtras } from '../../modules/test-config';

/**
 * Runtime configuration derived from the launch-intent extras (constitution §4).
 * Outside UI-test-mode these fall back to production defaults.
 */
export type TestConfig = {
  uiTestMode: boolean;
  mockAuthEmail: string | null;
  apiBaseUrl: string | null;
  apiKey: string | null;
  authorizedEmails: string[] | null;
  captureExternalLinks: boolean;
};

function toBool(v: string | null | undefined): boolean {
  if (v == null) return false;
  const s = String(v).trim().toLowerCase();
  return s === 'true' || s === '1' || s === 'yes';
}

function toStr(v: string | null | undefined): string | null {
  if (v == null) return null;
  const s = String(v).trim();
  return s.length > 0 ? s : null;
}

let cached: TestConfig | null = null;

/** Read once at startup. Extras are static for the process lifetime. */
export function loadTestConfig(): TestConfig {
  if (cached) return cached;
  const e = getRawExtras();
  const authorized = toStr(e.authorizedEmails);
  cached = {
    uiTestMode: toBool(e.uiTestMode),
    mockAuthEmail: toStr(e.mockAuthEmail),
    apiBaseUrl: toStr(e.apiBaseUrl),
    apiKey: toStr(e.apiKey),
    authorizedEmails: authorized
      ? authorized.split(',').map((s) => s.trim().toLowerCase()).filter(Boolean)
      : null,
    captureExternalLinks: toBool(e.captureExternalLinks),
  };
  return cached;
}

/** Test-only reset hook. */
export function __resetTestConfig() {
  cached = null;
}
