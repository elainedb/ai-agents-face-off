import React, { useState } from 'react';
import { View, Text, Pressable, StyleSheet, ActivityIndicator } from 'react-native';
import { IDS } from './selectors';
import { useAuthStore, useUiStore, useVideosStore } from '../state/stores';
import { getAppConfig } from '../state/appConfig';
import { realGoogleSignIn } from './auth/googleSignIn';

export default function LoginScreen() {
  const error = useAuthStore((s) => s.error);
  const signIn = useAuthStore((s) => s.signIn);
  const setScreen = useUiStore((s) => s.setScreen);
  const load = useVideosStore((s) => s.load);
  const [busy, setBusy] = useState(false);

  const onSignIn = async () => {
    if (busy) return;
    setBusy(true);
    try {
      const cfg = getAppConfig();
      let email: string | null;
      if (cfg.uiTestMode && cfg.mockAuthEmail != null) {
        // UI-test-mode: skip the account picker, sign in as the provided email (constitution §4).
        email = cfg.mockAuthEmail;
      } else {
        const res = await realGoogleSignIn();
        if (res.error && !res.email) {
          useAuthStore.setState({ error: res.error });
          return;
        }
        email = res.email;
      }
      const okAuth = signIn(email);
      if (okAuth) {
        setScreen('home');
        void load();
      }
    } finally {
      setBusy(false);
    }
  };

  return (
    <View style={styles.container} testID={IDS.screenLogin} accessibilityLabel={IDS.screenLogin}>
      <Text style={styles.title}>YouTube Dashboard</Text>
      <Text style={styles.subtitle}>Sign in to continue</Text>

      <Pressable
        testID={IDS.loginGoogleButton}
        accessibilityLabel={IDS.loginGoogleButton}
        style={styles.button}
        onPress={onSignIn}
      >
        {busy ? <ActivityIndicator color="#fff" /> : <Text style={styles.buttonText}>Sign in with Google</Text>}
      </Pressable>

      {error ? (
        <Text
          testID={IDS.loginErrorMessage}
          accessibilityLabel={IDS.loginErrorMessage}
          style={styles.error}
        >
          {error}
        </Text>
      ) : null}
    </View>
  );
}

const styles = StyleSheet.create({
  container: { flex: 1, alignItems: 'center', justifyContent: 'center', padding: 24, backgroundColor: '#fff' },
  title: { fontSize: 26, fontWeight: '700', marginBottom: 8, color: '#111' },
  subtitle: { fontSize: 15, color: '#555', marginBottom: 32 },
  button: {
    backgroundColor: '#c4302b',
    paddingVertical: 14,
    paddingHorizontal: 28,
    borderRadius: 8,
    minWidth: 240,
    alignItems: 'center',
  },
  buttonText: { color: '#fff', fontSize: 16, fontWeight: '600' },
  error: { marginTop: 20, color: '#b00020', fontSize: 14, textAlign: 'center' },
});
