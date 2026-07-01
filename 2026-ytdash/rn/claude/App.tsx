import { StatusBar } from 'expo-status-bar';
import React, { useEffect } from 'react';
import { StyleSheet, View } from 'react-native';

import { loadAppConfig } from './src/config/testConfig';
import { useStore } from './src/state/store';
import { DetailSheet } from './src/ui/DetailSheet';
import { ExternalOpenBanner } from './src/ui/ExternalOpenBanner';
import { HomeScreen } from './src/ui/HomeScreen';
import { LoginScreen } from './src/ui/LoginScreen';
import { MapScreen } from './src/ui/MapScreen';
import { LoadingView } from './src/ui/StateViews';

export default function App() {
  const config = useStore((s) => s.config);
  const screen = useStore((s) => s.screen);
  const init = useStore((s) => s.init);

  // Read the UI-test-mode launch extras once at startup (constitution §4).
  useEffect(() => {
    init(loadAppConfig());
  }, [init]);

  return (
    <View style={styles.root}>
      {!config ? (
        <LoadingView />
      ) : screen === 'login' ? (
        <LoginScreen />
      ) : screen === 'map' ? (
        <MapScreen />
      ) : (
        <HomeScreen />
      )}

      {/* Root overlays shared across screens (map detail sheet + external-open seam). */}
      <DetailSheet />
      <ExternalOpenBanner />
      <StatusBar style="auto" />
    </View>
  );
}

const styles = StyleSheet.create({
  root: { flex: 1, backgroundColor: '#fff' },
});
