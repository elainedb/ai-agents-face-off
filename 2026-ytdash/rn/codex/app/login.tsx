import { useEffect, useState } from 'react';
import { ActivityIndicator, Pressable, StyleSheet, Text, View } from 'react-native';
import { router } from 'expo-router';

import { getContainer } from '@/src/core/di/container';
import type { AuthStatus } from '@/src/features/authentication/presentation/stores/auth-store';

interface AuthSnapshot {
  status: AuthStatus;
  errorMessage: string | null;
}

export default function LoginScreen() {
  const authStore = getContainer().authStore;
  const [authSnapshot, setAuthSnapshot] = useState<AuthSnapshot>(() => ({
    status: authStore.getState().status,
    errorMessage: authStore.getState().errorMessage,
  }));

  useEffect(() => {
    const unsubscribe = authStore.subscribe((state) => {
      setAuthSnapshot({
        status: state.status,
        errorMessage: state.errorMessage,
      });
    });

    return unsubscribe;
  }, [authStore]);

  useEffect(() => {
    void authStore.getState().checkAuthStatus();
  }, [authStore]);

  useEffect(() => {
    if (authSnapshot.status === 'authenticated') {
      router.replace('/main');
    }
  }, [authSnapshot.status]);

  const isLoading = authSnapshot.status === 'loading' || authSnapshot.status === 'initial';

  return (
    <View style={styles.screen}>
      <View style={styles.card}>
        <Text style={styles.eyebrow}>Android build</Text>
        <Text style={styles.title}>Login with Google</Text>
        <Text style={styles.subtitle}>
          Access is limited to the authorized email list configured for this app.
        </Text>
        <Pressable
          disabled={isLoading}
          onPress={() => void authStore.getState().signIn()}
          style={[styles.button, isLoading && styles.buttonDisabled]}>
          {isLoading ? (
            <ActivityIndicator color="#ffffff" />
          ) : (
            <Text style={styles.buttonText}>Sign in with Google</Text>
          )}
        </Pressable>
        {authSnapshot.errorMessage ? (
          <Text style={styles.errorText}>{authSnapshot.errorMessage}</Text>
        ) : null}
      </View>
    </View>
  );
}

const styles = StyleSheet.create({
  screen: {
    flex: 1,
    justifyContent: 'center',
    padding: 24,
    backgroundColor: '#eef4ff',
  },
  card: {
    backgroundColor: '#ffffff',
    borderRadius: 28,
    padding: 24,
    gap: 14,
    borderWidth: 1,
    borderColor: '#dce7ff',
  },
  eyebrow: {
    color: '#4468a8',
    fontWeight: '700',
    textTransform: 'uppercase',
    letterSpacing: 1,
  },
  title: {
    fontSize: 32,
    lineHeight: 36,
    color: '#13203a',
    fontWeight: '800',
  },
  subtitle: {
    color: '#596b8d',
    fontSize: 15,
    lineHeight: 22,
  },
  button: {
    marginTop: 6,
    backgroundColor: '#4285F4',
    borderRadius: 18,
    minHeight: 56,
    alignItems: 'center',
    justifyContent: 'center',
  },
  buttonDisabled: {
    opacity: 0.8,
  },
  buttonText: {
    color: '#ffffff',
    fontWeight: '700',
    fontSize: 16,
  },
  errorText: {
    color: '#d32f2f',
    fontWeight: '600',
  },
});
