import { useEffect } from 'react';
import { StyleSheet, View } from 'react-native';

import { useAuthStore } from './src/state/authStore';
import { useNavStore } from './src/state/navStore';
import { useVideoStore } from './src/state/videoStore';
import { ExternalLinkBanner } from './src/ui/components/ExternalLinkBanner';
import { HomeScreen } from './src/ui/screens/HomeScreen';
import { LoginScreen } from './src/ui/screens/LoginScreen';
import { MapScreen } from './src/ui/screens/MapScreen';

export default function App() {
  const authStatus = useAuthStore((s) => s.status);
  const screen = useNavStore((s) => s.screen);
  const goHome = useNavStore((s) => s.goHome);
  const goLogin = useNavStore((s) => s.goLogin);
  const refreshVideos = useVideoStore((s) => s.refresh);

  useEffect(() => {
    if (authStatus === 'signed_in') {
      goHome();
      refreshVideos();
    } else {
      goLogin();
    }
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [authStatus]);

  return (
    <View style={styles.container}>
      {screen === 'login' ? <LoginScreen /> : null}
      {screen === 'home' ? <HomeScreen /> : null}
      {screen === 'map' ? <MapScreen /> : null}
      <ExternalLinkBanner />
    </View>
  );
}

const styles = StyleSheet.create({
  container: { flex: 1 },
});
