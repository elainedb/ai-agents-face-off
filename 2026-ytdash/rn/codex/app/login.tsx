import { router } from 'expo-router';
import {
  ActivityIndicator,
  Platform,
  Pressable,
  StyleSheet,
  Text,
  View,
} from 'react-native';
import { SafeAreaView } from 'react-native-safe-area-context';

import { useAuthStore } from '@/src/features/authentication/presentation/stores/auth-store';

export default function LoginScreen() {
  const { status, errorMessage, signIn } = useAuthStore();

  return (
    <SafeAreaView style={styles.safeArea}>
      <View style={styles.container}>
        <Text style={styles.eyebrow}>Android Build</Text>
        <Text style={styles.title}>Login with Google</Text>
        <Text style={styles.subtitle}>
          Access is restricted to the configured email whitelist.
        </Text>
        <Pressable
          disabled={status === 'loading'}
          style={[styles.button, status === 'loading' && styles.buttonDisabled]}
          onPress={() => {
            void signIn().then((success) => {
              if (success) {
                router.replace('/main');
              }
            });
          }}>
          {status === 'loading' ? (
            <ActivityIndicator color="#FFFFFF" />
          ) : (
            <Text style={styles.buttonText}>Sign in with Google</Text>
          )}
        </Pressable>
        {errorMessage ? <Text style={styles.error}>{errorMessage}</Text> : null}
        {Platform.OS !== 'android' ? (
          <Text style={styles.note}>This build only enables sign-in on Android.</Text>
        ) : null}
      </View>
    </SafeAreaView>
  );
}

const styles = StyleSheet.create({
  safeArea: {
    flex: 1,
    backgroundColor: '#F2F5FB',
  },
  container: {
    flex: 1,
    alignItems: 'center',
    justifyContent: 'center',
    paddingHorizontal: 24,
    backgroundColor: '#F2F5FB',
  },
  eyebrow: {
    textTransform: 'uppercase',
    letterSpacing: 1.6,
    color: '#4285F4',
    fontWeight: '700',
    marginBottom: 12,
  },
  title: {
    fontSize: 34,
    fontWeight: '800',
    color: '#14213D',
    marginBottom: 12,
  },
  subtitle: {
    textAlign: 'center',
    color: '#52627B',
    fontSize: 16,
    lineHeight: 24,
    marginBottom: 28,
  },
  button: {
    width: '100%',
    borderRadius: 18,
    backgroundColor: '#4285F4',
    paddingVertical: 16,
    alignItems: 'center',
  },
  buttonDisabled: {
    opacity: 0.75,
  },
  buttonText: {
    color: '#FFFFFF',
    fontSize: 16,
    fontWeight: '700',
  },
  error: {
    marginTop: 16,
    color: '#D32F2F',
    textAlign: 'center',
  },
  note: {
    marginTop: 20,
    color: '#52627B',
  },
});
