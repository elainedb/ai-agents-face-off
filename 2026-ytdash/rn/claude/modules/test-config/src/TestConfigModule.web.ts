import { registerWebModule, NativeModule } from 'expo';

import { RawTestConfig } from './TestConfig.types';

// Web/Node (e.g. jest) fallback: no Android intent extras exist, so UI test mode is always off.
class TestConfigModule extends NativeModule<{}> {
  get(): RawTestConfig {
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
