import { useEffect } from 'react';
import { View, Text, TouchableOpacity, StyleSheet, ActivityIndicator } from 'react-native';
import { router } from 'expo-router';
import { useAuthStore } from '@/src/features/authentication/presentation/stores/auth-store';

export default function LoginScreen() {
  const { status, errorMessage, signIn } = useAuthStore();

  useEffect(() => {
    if (status === 'authenticated') {
      router.replace('/main');
    }
  }, [status]);

  const isLoading = status === 'loading';

  return (
    <View style={styles.container}>
      <Text style={styles.title}>Login with Google</Text>

      <TouchableOpacity
        style={[styles.button, isLoading && styles.buttonDisabled]}
        onPress={signIn}
        disabled={isLoading}
      >
        {isLoading ? (
          <ActivityIndicator color="#fff" />
        ) : (
          <Text style={styles.buttonText}>Sign in with Google</Text>
        )}
      </TouchableOpacity>

      {errorMessage && <Text style={styles.error}>{errorMessage}</Text>}
    </View>
  );
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
    justifyContent: 'center',
    alignItems: 'center',
    padding: 24,
    backgroundColor: '#fff',
  },
  title: {
    fontSize: 28,
    fontWeight: '700',
    marginBottom: 40,
    color: '#333',
  },
  button: {
    backgroundColor: '#4285F4',
    paddingHorizontal: 32,
    paddingVertical: 14,
    borderRadius: 8,
    minWidth: 220,
    alignItems: 'center',
  },
  buttonDisabled: {
    opacity: 0.7,
  },
  buttonText: {
    color: '#fff',
    fontSize: 16,
    fontWeight: '600',
  },
  error: {
    color: '#d32f2f',
    marginTop: 16,
    fontSize: 14,
    textAlign: 'center',
  },
});
