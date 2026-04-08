import { useEffect, useState } from 'react';
import { ActivityIndicator, StyleSheet, View } from 'react-native';
import { router } from 'expo-router';

import { getContainer } from '@/src/core/di/container';
import type { AuthStatus } from '@/src/features/authentication/presentation/stores/auth-store';

export default function IndexScreen() {
  const authStore = getContainer().authStore;
  const [status, setStatus] = useState<AuthStatus>(() => authStore.getState().status);

  useEffect(() => {
    const unsubscribe = authStore.subscribe((state) => {
      setStatus(state.status);
    });

    return unsubscribe;
  }, [authStore]);

  useEffect(() => {
    void authStore.getState().checkAuthStatus();
  }, [authStore]);

  useEffect(() => {
    if (status === 'authenticated') {
      router.replace('/main');
      return;
    }

    if (status === 'unauthenticated' || status === 'error') {
      router.replace('/login');
    }
  }, [status]);

  return (
    <View style={styles.container}>
      <ActivityIndicator size="large" color="#4285F4" />
    </View>
  );
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
    alignItems: 'center',
    justifyContent: 'center',
    backgroundColor: '#eef4ff',
  },
});
