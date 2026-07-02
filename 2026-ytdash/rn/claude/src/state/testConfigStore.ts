import { create } from 'zustand';

import { ResolvedConfig, resolveTestConfig } from '../native/testConfig';

// Resolved once at process start from the launch-intent extras (or production defaults). A
// relaunch (Maestro's `launchApp`) restarts the whole JS environment, so "once at module init" is
// equivalent to "once per app launch" — exactly the UI-test-mode contract's granularity.
export const useTestConfigStore = create<ResolvedConfig>(() => resolveTestConfig());
