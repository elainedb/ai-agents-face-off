import { useEffect } from 'react';
import {
  View,
  Text,
  StyleSheet,
  TouchableOpacity,
  ActivityIndicator,
  SafeAreaView,
} from 'react-native';
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
    <SafeAreaView style={styles.container}>
      <View style={styles.content}>
        <Text style={styles.title}>Login with Google</Text>

        <TouchableOpacity
          style={[styles.button, isLoading && styles.buttonDisabled]}
          onPress={signIn}
          disabled={isLoading}
          activeOpacity={0.7}
        >
          {isLoading ? (
            <ActivityIndicator color="#fff" />
          ) : (
            <Text style={styles.buttonText}>Sign in with Google</Text>
          )}
        </TouchableOpacity>

        {errorMessage && <Text style={styles.error}>{errorMessage}</Text>}
      </View>
    </SafeAreaView>
  );
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: '#fff',
  },
  content: {
    flex: 1,
    justifyContent: 'center',
    alignItems: 'center',
    paddingHorizontal: 32,
  },
  title: {
    fontSize: 28,
    fontWeight: '700',
    color: '#212121',
    marginBottom: 32,
  },
  button: {
    backgroundColor: '#4285F4',
    paddingVertical: 14,
    paddingHorizontal: 32,
    borderRadius: 8,
    width: '100%',
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
    fontSize: 14,
    marginTop: 16,
    textAlign: 'center',
  },
});
