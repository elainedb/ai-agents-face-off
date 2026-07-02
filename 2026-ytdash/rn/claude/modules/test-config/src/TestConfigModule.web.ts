import { registerWebModule, NativeModule } from 'expo';

import { TestConfig } from './TestConfig.types';

class TestConfigModule extends NativeModule<{}> {
  getConfig(): TestConfig {
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

export default registerWebModule(TestConfigModule, 'TestConfigModule');
