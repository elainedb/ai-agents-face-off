import { requireOptionalNativeModule } from 'expo';

// Raw launch-intent extras surfaced from the Android Activity. Every value is a string
// (the native module normalizes via toString) so JS can coerce booleans uniformly.
export type RawExtras = Record<string, string | null | undefined>;

type TestConfigNativeModule = {
  getConfig(): RawExtras;
};

// Optional: when running on web / in a context without the native module (e.g. Jest),
// this is null and the caller falls back to production defaults.
const native = requireOptionalNativeModule<TestConfigNativeModule>('TestConfig');

export function getRawExtras(): RawExtras {
  try {
    return native?.getConfig() ?? {};
  } catch {
    return {};
  }
}
