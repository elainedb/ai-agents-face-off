import React from 'react';
import { ActivityIndicator, Pressable, StyleSheet, Text, View } from 'react-native';

import { useStore } from '../state/store';

export function LoginScreen() {
  const signIn = useStore((s) => s.signIn);
  const signingIn = useStore((s) => s.signingIn);
  const authError = useStore((s) => s.authError);

  return (
    <View testID="screen_login" style={styles.container}>
      <Text style={styles.title}>ytdash</Text>
      <Text style={styles.subtitle}>YouTube Dashboard</Text>

      <Pressable
        testID="login_google_button"
        style={styles.button}
        disabled={signingIn}
        onPress={() => signIn()}
      >
        <Text style={styles.buttonText}>Sign in with Google</Text>
      </Pressable>

      {signingIn ? <ActivityIndicator testID="loading_indicator" style={styles.spinner} color="#c00" /> : null}

      {authError ? (
        <Text testID="login_error_message" style={styles.error}>
          {authError}
        </Text>
      ) : null}
    </View>
  );
}

const styles = StyleSheet.create({
  container: { flex: 1, alignItems: 'center', justifyContent: 'center', padding: 24, gap: 16, backgroundColor: '#fff' },
  title: { fontSize: 36, fontWeight: '800', color: '#c00' },
  subtitle: { fontSize: 16, color: '#666', marginBottom: 24 },
  button: { backgroundColor: '#4285F4', paddingHorizontal: 28, paddingVertical: 14, borderRadius: 8 },
  buttonText: { color: '#fff', fontWeight: '700', fontSize: 16 },
  spinner: { marginTop: 8 },
  error: { color: '#b00020', fontSize: 15, textAlign: 'center', marginTop: 12, paddingHorizontal: 16 },
});
