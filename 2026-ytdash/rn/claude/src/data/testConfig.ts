import type { TestConfig } from '../domain/models';
import TestconfigModule from '../../modules/testconfig/src/TestconfigModule';

const DEFAULT_CONFIG: TestConfig = {
  uiTestMode: false,
  mockAuthEmail: null,
  apiBaseUrl: 'https://www.googleapis.com',
  apiKey: null,
  authorizedEmails: null,
  captureExternalLinks: false,
};

let cached: TestConfig | null = null;

export function loadTestConfig(): TestConfig {
  if (cached) return cached;
  try {
    const native = TestconfigModule.getTestConfig();
    cached = {
      uiTestMode: !!native.uiTestMode,
      mockAuthEmail: native.mockAuthEmail ?? null,
      apiBaseUrl: native.apiBaseUrl ?? DEFAULT_CONFIG.apiBaseUrl,
      apiKey: native.apiKey ?? null,
      authorizedEmails: native.authorizedEmails ?? null,
      captureExternalLinks: !!native.captureExternalLinks,
    };
  } catch {
    cached = DEFAULT_CONFIG;
  }
  return cached;
}
