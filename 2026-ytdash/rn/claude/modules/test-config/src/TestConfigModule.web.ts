import { registerWebModule, NativeModule } from 'expo';

import { NativeTestConfig } from './TestConfig.types';

// Web has no launch intent; return production defaults.
class TestConfigModule extends NativeModule {
  getConfig(): NativeTestConfig {
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

export default registerWebModule(TestConfigModule, 'TestConfig');
