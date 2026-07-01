import { requireNativeModule } from 'expo-modules-core';

export type NativeTestConfig = {
  uiTestMode: boolean;
  mockAuthEmail: string | null;
  apiBaseUrl: string | null;
  apiKey: string | null;
  authorizedEmails: string | null;
  captureExternalLinks: boolean;
};

// The native module is only present on Android release/dev builds after prebuild. Guard the
// require so Metro/web/tests degrade gracefully to defaults.
let nativeModule: { getTestConfig: () => NativeTestConfig } | null = null;
try {
  nativeModule = requireNativeModule('TestConfig');
} catch {
  nativeModule = null;
}

const DEFAULTS: NativeTestConfig = {
  uiTestMode: false,
  mockAuthEmail: null,
  apiBaseUrl: null,
  apiKey: null,
  authorizedEmails: null,
  captureExternalLinks: false,
};

export function getTestConfig(): NativeTestConfig {
  if (!nativeModule) return DEFAULTS;
  try {
    return { ...DEFAULTS, ...nativeModule.getTestConfig() };
  } catch {
    return DEFAULTS;
  }
}
