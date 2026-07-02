import { NativeModule, requireNativeModule } from 'expo';

import { RawTestConfig } from './TestConfig.types';

declare class TestConfigModule extends NativeModule<{}> {
  get(): RawTestConfig;
}

export default requireNativeModule<TestConfigModule>('TestConfig');
