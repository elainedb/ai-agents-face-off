import { NativeModule, requireNativeModule } from 'expo';

import { NativeTestConfig } from './TestConfig.types';

declare class TestConfigModule extends NativeModule {
  getConfig(): NativeTestConfig;
}

export default requireNativeModule<TestConfigModule>('TestConfig');
