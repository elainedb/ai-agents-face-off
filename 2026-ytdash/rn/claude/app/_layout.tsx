import 'react-native-gesture-handler';
import React from 'react';
import { Stack } from 'expo-router';
import { SafeAreaProvider } from 'react-native-safe-area-context';
import { ExternalLinkBanner } from '../src/components/ExternalLinkBanner';
import { loadTestConfig } from '../src/state/testConfig';

// Read launch-intent extras once, before any screen renders, so the whole app boots with a
// stable, consistent config (mock vs real base URL/key, whitelist, test-mode flags).
loadTestConfig();

export default function RootLayout() {
  return (
    <SafeAreaProvider>
      <Stack screenOptions={{ headerShown: false }} />
      <ExternalLinkBanner />
    </SafeAreaProvider>
  );
}
