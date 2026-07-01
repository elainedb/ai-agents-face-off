import TestConfigModule from './src/TestConfigModule';
import { NativeTestConfig } from './src/TestConfig.types';

export { NativeTestConfig };

// Read the UI-test-mode launch config (Android intent extras). Never throws — falls back to
// production defaults if the native module is unavailable for any reason.
export function getNativeTestConfig(): NativeTestConfig {
  try {
    return TestConfigModule.getConfig();
  } catch {
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
