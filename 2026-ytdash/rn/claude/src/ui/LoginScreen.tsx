import React, { useState } from 'react';
import { ActivityIndicator, Pressable, StyleSheet, Text, View } from 'react-native';
import { resolveConfig } from '../appConfig';
import { realGoogleSignIn } from '../auth/googleSignIn';
import { useAuthStore } from '../state/authStore';
import { useVideoStore } from '../state/videoStore';

export function LoginScreen() {
  const cfg = resolveConfig();
  const errorMessage = useAuthStore((s) => s.errorMessage);
  const signInWithEmail = useAuthStore((s) => s.signInWithEmail);
  const load = useVideoStore((s) => s.load);
  const [busy, setBusy] = useState(false);

  const onSignIn = async () => {
    setBusy(true);
    try {
      // UI-test-mode swaps the non-deterministic account picker for a fixed email (constitution §4).
      const email =
        cfg.uiTestMode && cfg.mockAuthEmail ? cfg.mockAuthEmail : await realGoogleSignIn();
      const granted = signInWithEmail(email, cfg);
      if (granted) {
        void load(cfg);
      }
    } finally {
      setBusy(false);
    }
  };

  return (
    <View testID="screen_login" style={styles.container}>
      <Text style={styles.title}>ytdash</Text>
      <Text style={styles.subtitle}>YouTube Dashboard</Text>
      <Pressable
        testID="login_google_button"
        accessibilityRole="button"
        onPress={onSignIn}
        style={styles.button}
      >
        {busy ? (
          <ActivityIndicator color="#fff" />
        ) : (
          <Text style={styles.buttonText}>Sign in with Google</Text>
        )}
      </Pressable>
      {errorMessage ? (
        <Text testID="login_error_message" style={styles.error}>
          {errorMessage}
        </Text>
      ) : null}
    </View>
  );
}

const styles = StyleSheet.create({
  container: { flex: 1, alignItems: 'center', justifyContent: 'center', padding: 24, backgroundColor: '#fff' },
  title: { fontSize: 34, fontWeight: '700', color: '#111827' },
  subtitle: { fontSize: 16, color: '#6b7280', marginBottom: 40 },
  button: { backgroundColor: '#dc2626', paddingVertical: 14, paddingHorizontal: 28, borderRadius: 8, minWidth: 240, alignItems: 'center' },
  buttonText: { color: '#fff', fontSize: 16, fontWeight: '600' },
  error: { color: '#b91c1c', marginTop: 24, textAlign: 'center', fontSize: 14 },
});
