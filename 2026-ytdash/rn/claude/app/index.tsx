import { useEffect } from 'react';
import { router } from 'expo-router';
import { View, ActivityIndicator, StyleSheet } from 'react-native';
import { useAuthStore } from '@/src/features/authentication/presentation/stores/auth-store';

export default function IndexScreen() {
  const { checkAuthStatus, status } = useAuthStore();

  useEffect(() => {
    checkAuthStatus();
  }, []);

  useEffect(() => {
    if (status === 'authenticated') {
      router.replace('/main');
    } else if (status === 'unauthenticated' || status === 'error') {
      router.replace('/login');
    }
  }, [status]);

  return (
    <View style={styles.container}>
      <ActivityIndicator size="large" />
    </View>
  );
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
    justifyContent: 'center',
    alignItems: 'center',
  },
});
