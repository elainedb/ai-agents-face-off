import { NativeModule, requireNativeModule } from 'expo';

import type { TestConfig } from './Testconfig.types';

declare class TestconfigModule extends NativeModule<{}> {
  getTestConfig(): TestConfig;
}

export default requireNativeModule<TestconfigModule>('Testconfig');
