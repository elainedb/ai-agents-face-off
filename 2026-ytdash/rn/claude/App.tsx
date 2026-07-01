import { StatusBar } from 'expo-status-bar';
import React from 'react';
import { SafeAreaView, StyleSheet } from 'react-native';
import { ExternalBanner } from './src/ui/ExternalBanner';
import { HomeScreen } from './src/ui/HomeScreen';
import { LoginScreen } from './src/ui/LoginScreen';
import { MapScreen } from './src/ui/MapScreen';
import { useAuthStore } from './src/state/authStore';
import { useNavStore } from './src/state/navStore';

function AuthedApp() {
  const screen = useNavStore((s) => s.screen);
  return screen === 'map' ? <MapScreen /> : <HomeScreen />;
}

export default function App() {
  const loggedIn = useAuthStore((s) => s.loggedIn);
  return (
    <SafeAreaView style={styles.root}>
      {loggedIn ? <AuthedApp /> : <LoginScreen />}
      {/* App-root banner so both the list and the map sheet feed the same external-open surface. */}
      <ExternalBanner />
      <StatusBar style="auto" />
    </SafeAreaView>
  );
}

const styles = StyleSheet.create({
  root: { flex: 1, backgroundColor: '#fff' },
});
