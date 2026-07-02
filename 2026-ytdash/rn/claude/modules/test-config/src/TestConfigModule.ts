import { NativeModule, requireNativeModule } from 'expo';

import { TestConfig } from './TestConfig.types';

declare class TestConfigModule extends NativeModule<{}> {
  getConfig(): TestConfig;
}

export default requireNativeModule<TestConfigModule>('TestConfig');
