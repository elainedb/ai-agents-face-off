import React, { useEffect } from 'react';
import { Pressable, StyleSheet, Text, View } from 'react-native';
import { useRouter } from 'expo-router';
import * as Google from 'expo-auth-session/providers/google';
import * as WebBrowser from 'expo-web-browser';
import Constants from 'expo-constants';
import { useAuthStore } from '../src/state/authStore';
import { getTestConfig } from '../src/state/testConfig';

WebBrowser.maybeCompleteAuthSession();

async function fetchGoogleEmail(accessToken: string): Promise<string> {
  const res = await fetch('https://www.googleapis.com/oauth2/v3/userinfo', {
    headers: { Authorization: `Bearer ${accessToken}` },
  });
  if (!res.ok) throw new Error('Could not read the Google account email.');
  const json = await res.json();
  if (!json.email) throw new Error('Google account has no email.');
  return json.email as string;
}

export default function Login() {
  const router = useRouter();
  const status = useAuthStore((s) => s.status);
  const errorMessage = useAuthStore((s) => s.errorMessage);
  const signInWithMockEmail = useAuthStore((s) => s.signInWithMockEmail);
  const signInWithEmail = useAuthStore((s) => s.signInWithEmail);
  const signInFailed = useAuthStore((s) => s.signInFailed);

  useEffect(() => {
    if (status === 'signedIn') {
      router.replace('/home');
    }
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [status]);

  // expo-auth-session's Google provider throws synchronously (during hook creation, not just at
  // prompt time) if androidClientId is undefined. This workspace has no OAuth client id
  // configured (see plan.md deviations), so fall back to a placeholder that satisfies the
  // invariant without ever being used to actually prompt — `isGoogleConfigured` gates that.
  const configuredAndroidClientId = Constants.expoConfig?.extra?.googleAndroidClientId as string;
  const isGoogleConfigured = Boolean(configuredAndroidClientId);
  const androidClientId = configuredAndroidClientId || 'UNCONFIGURED';
  const webClientId = (Constants.expoConfig?.extra?.googleWebClientId as string) || undefined;

  const [request, response, promptAsync] = Google.useAuthRequest({
    androidClientId,
    webClientId,
    responseType: 'token',
    scopes: ['profile', 'email'],
  });

  useEffect(() => {
    if (response?.type === 'success' && response.authentication?.accessToken) {
      fetchGoogleEmail(response.authentication.accessToken)
        .then((email) => signInWithEmail(email))
        .catch((err) => signInFailed(err instanceof Error ? err.message : 'Google sign-in failed.'));
    } else if (response?.type === 'error') {
      signInFailed('Google sign-in failed.');
    }
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [response]);

  const handlePress = () => {
    const cfg = getTestConfig();
    if (cfg.uiTestMode) {
      signInWithMockEmail();
      return;
    }
    if (!isGoogleConfigured || !request) {
      signInFailed('Google Sign-In is not configured in this build.');
      return;
    }
    promptAsync().catch(() => signInFailed('Google sign-in failed.'));
  };

  return (
    <View testID="screen_login" style={styles.container}>
      <Text style={styles.title}>ytdash</Text>
      <Text style={styles.subtitle}>Sign in to see the latest videos from your channels.</Text>
      <Pressable testID="login_google_button" style={styles.button} onPress={handlePress}>
        <Text style={styles.buttonText}>Sign in with Google</Text>
      </Pressable>
      {status === 'unauthorized' && errorMessage ? (
        <Text testID="login_error_message" style={styles.error}>
          {errorMessage}
        </Text>
      ) : null}
    </View>
  );
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
    alignItems: 'center',
    justifyContent: 'center',
    padding: 24,
    gap: 16,
    backgroundColor: 'white',
  },
  title: {
    fontSize: 28,
    fontWeight: '700',
  },
  subtitle: {
    textAlign: 'center',
    color: '#6b7280',
  },
  button: {
    backgroundColor: '#dc2626',
    paddingHorizontal: 24,
    paddingVertical: 14,
    borderRadius: 8,
  },
  buttonText: {
    color: 'white',
    fontWeight: '600',
    fontSize: 16,
  },
  error: {
    color: '#dc2626',
    textAlign: 'center',
  },
});
