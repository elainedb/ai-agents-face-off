import { useRouter } from 'expo-router';
import { useEffect } from 'react';
import {
  ActivityIndicator,
  Pressable,
  StyleSheet,
  Text,
  View,
} from 'react-native';
import { SafeAreaView } from 'react-native-safe-area-context';

import { useAuthStore } from '@/src/features/authentication/presentation/stores/auth-store';

export default function LoginScreen() {
  const router = useRouter();
  const { status, errorMessage, checkAuthStatus, signIn } = useAuthStore();

  useEffect(() => {
    checkAuthStatus().catch(() => undefined);
  }, [checkAuthStatus]);

  useEffect(() => {
    if (status === 'authenticated') {
      router.replace('/main');
    }
  }, [router, status]);

  return (
    <SafeAreaView style={styles.safeArea}>
      <View style={styles.container}>
        <Text style={styles.eyebrow}>Android Build</Text>
        <Text style={styles.title}>Login with Google</Text>
        <Text style={styles.subtitle}>
          Sign in with an authorized Google account to access the YouTube dashboard.
        </Text>

        <Pressable
          disabled={status === 'loading'}
          onPress={() => signIn().catch(() => undefined)}
          style={[styles.button, status === 'loading' && styles.buttonDisabled]}>
          {status === 'loading' ? (
            <ActivityIndicator color="#fff" />
          ) : (
            <Text style={styles.buttonText}>Sign in with Google</Text>
          )}
        </Pressable>

        {errorMessage ? <Text style={styles.errorText}>{errorMessage}</Text> : null}
      </View>
    </SafeAreaView>
  );
}

const styles = StyleSheet.create({
  safeArea: {
    flex: 1,
    backgroundColor: '#f4f7fb',
  },
  container: {
    flex: 1,
    justifyContent: 'center',
    paddingHorizontal: 24,
    gap: 14,
  },
  eyebrow: {
    color: '#4285F4',
    fontSize: 14,
    fontWeight: '700',
    textTransform: 'uppercase',
    letterSpacing: 1.2,
  },
  title: {
    color: '#102030',
    fontSize: 34,
    fontWeight: '800',
  },
  subtitle: {
    color: '#51667d',
    fontSize: 16,
    lineHeight: 24,
    marginBottom: 18,
  },
  button: {
    backgroundColor: '#4285F4',
    borderRadius: 18,
    paddingVertical: 16,
    alignItems: 'center',
    justifyContent: 'center',
    minHeight: 56,
  },
  buttonDisabled: {
    opacity: 0.8,
  },
  buttonText: {
    color: '#fff',
    fontSize: 16,
    fontWeight: '700',
  },
  errorText: {
    color: '#d32f2f',
    fontSize: 14,
  },
});
