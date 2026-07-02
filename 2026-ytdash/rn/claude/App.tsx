import { StatusBar } from 'expo-status-bar';
import React, { useState } from 'react';
import { StyleSheet, View } from 'react-native';

import { useAuthStore } from './src/state/authStore';
import { useVideoStore } from './src/state/videoStore';
import { ExternalLinkBanner } from './src/ui/components/ExternalLinkBanner';
import { HomeScreen } from './src/ui/screens/HomeScreen';
import { LoginScreen } from './src/ui/screens/LoginScreen';
import { MapScreen } from './src/ui/screens/MapScreen';

type Screen = 'home' | 'map';

export default function App() {
  const authorized = useAuthStore((s) => s.authorized);
  const logout = useAuthStore((s) => s.logout);
  const [screen, setScreen] = useState<Screen>('home');

  const handleLogout = () => {
    setScreen('home');
    useVideoStore.getState().reset();
    logout();
  };

  return (
    <View style={styles.container}>
      {authorized ? (
        screen === 'map' ? (
          <MapScreen onBack={() => setScreen('home')} />
        ) : (
          <HomeScreen onNavigateMap={() => setScreen('map')} onLogout={handleLogout} />
        )
      ) : (
        <LoginScreen />
      )}
      <ExternalLinkBanner />
      <StatusBar style="auto" />
    </View>
  );
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
  },
});
