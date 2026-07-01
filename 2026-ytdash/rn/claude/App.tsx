import React from 'react';
import { View, StyleSheet, StatusBar } from 'react-native';
import { useUiStore } from './src/state/stores';
import LoginScreen from './src/ui/LoginScreen';
import HomeScreen from './src/ui/HomeScreen';
import MapScreen from './src/ui/MapScreen';
import ExternalBanner from './src/ui/ExternalBanner';

export default function App() {
  const screen = useUiStore((s) => s.screen);

  return (
    <View style={styles.root}>
      <StatusBar barStyle="dark-content" />
      {screen === 'login' ? <LoginScreen /> : screen === 'map' ? <MapScreen /> : <HomeScreen />}
      {/* Lifted to the root so the list and the map sheet share one banner (constitution §5/C). */}
      <ExternalBanner />
    </View>
  );
}

const styles = StyleSheet.create({
  root: { flex: 1, backgroundColor: '#fff' },
});
