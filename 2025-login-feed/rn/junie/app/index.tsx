import React, { useCallback, useEffect, useState } from 'react';
import { View, Text, Button, StyleSheet, Platform } from 'react-native';
import { GoogleSignin, statusCodes } from '@react-native-google-signin/google-signin';
import { useRouter } from 'expo-router';

import Constants from 'expo-constants';

// Authorized emails are provided via Expo config (app.config.js -> extra.authorizedEmails)
const authorizedEmails: string[] = Array.isArray(Constants.expoConfig?.extra?.authorizedEmails)
  ? (Constants.expoConfig!.extra!.authorizedEmails as string[])
  : [];
const authorizedSource: string | undefined = (Constants.expoConfig as any)?.extra?.__authorizedEmailsSource;

function log(tag: string, message: string, extra?: any) {
  const ts = new Date().toISOString();
  if (extra !== undefined) {
    console.log(`[Login ${tag}] ${ts} - ${message}`, extra);
  } else {
    console.log(`[Login ${tag}] ${ts} - ${message}`);
  }
}

export default function LoginScreen() {
  const router = useRouter();
  const [error, setError] = useState<string | null>(null);
  const [loading, setLoading] = useState(false);

  useEffect(() => {
    log('INIT', 'Configuring Google Signin');
    log('CONFIG', 'Authorized emails loaded', { count: authorizedEmails.length, source: authorizedSource });
    // Configure Google Sign-In. webClientId is required to obtain an ID token
    // (and for proper behavior on iOS); it's the OAuth 2.0 Client ID for Web.
    GoogleSignin.configure({
      webClientId:
        '83953880984-7n5mp2qaj2i9nqom6gohaqht00a88rbb.apps.googleusercontent.com',
      scopes: ['email', 'profile'],
      // offlineAccess: false,
      // forceCodeForRefreshToken: false,
    });
  }, []);

  const handleSignIn = useCallback(async () => {
    setError(null);
    setLoading(true);
    try {
      log('FLOW', 'Sign-in started');
      if (Platform.OS === 'android') {
        // Ensure Google Play Services are available
        log('CHECK', 'Checking Google Play Services');
        await GoogleSignin.hasPlayServices({ showPlayServicesUpdateDialog: true });
      }

      // Clear any cached session to force the account chooser to appear
      try {
        log('RESET', 'Revoking access');
        await GoogleSignin.revokeAccess();
      } catch (e) {
        log('RESET', 'Revoking access failed (ignored)', e);
      }
      try {
        log('RESET', 'Signing out pre-existing session');
        await GoogleSignin.signOut();
      } catch (e) {
        log('RESET', 'Sign out pre-existing session failed (ignored)', e);
      }

      log('ACTION', 'Calling GoogleSignin.signIn');
      const userInfo = await GoogleSignin.signIn();
      log('RESULT', 'signIn resolved', { user: userInfo?.user });
      let email = userInfo?.user?.email ?? '';

      if (!email) {
        // Try to read from current user as a fallback (in case signIn resolved without full profile)
        log('FALLBACK', 'Reading current user after signIn');
        const current = await GoogleSignin.getCurrentUser();
        log('RESULT', 'getCurrentUser resolved', { user: current?.user });
        email = current?.user?.email ?? '';
      }

      if (!email) {
        // Treat as cancelled/incomplete instead of unauthorized
        log('WARN', 'No email resolved from sign-in; treat as cancelled/incomplete');
        setError('Sign-in was cancelled or did not complete. Please try again and select an account.');
        return;
      }

      if (authorizedEmails.includes(email)) {
        log('AUTH', `Access granted for ${email}`);
        // Navigate to the Account screen which shows email and logout
        log('NAV', 'Navigating to /account via router.replace');
        router.replace('/account');
      } else {
        log('AUTH', `Access denied for ${email}`);
        setError('Access denied. Your email is not authorized.');
      }
    } catch (e: any) {
      // Handle known Google Sign-In status codes gracefully
      if (e?.code === statusCodes.SIGN_IN_CANCELLED) {
        log('ERROR', 'SIGN_IN_CANCELLED');
        setError('Sign-in was cancelled.');
      } else if (e?.code === statusCodes.IN_PROGRESS) {
        log('ERROR', 'IN_PROGRESS');
        setError('Sign-in is already in progress.');
      } else if (e?.code === statusCodes.PLAY_SERVICES_NOT_AVAILABLE) {
        log('ERROR', 'PLAY_SERVICES_NOT_AVAILABLE');
        setError('Google Play Services is not available or outdated.');
      } else {
        log('ERROR', 'Unknown Google Sign-In error', e);
        setError(e?.message || 'An unexpected error occurred during sign-in.');
      }
    } finally {
      setLoading(false);
      log('FLOW', 'Sign-in finished');
    }
  }, [router]);

  return (
    <View style={styles.container}>
      <Text style={styles.title}>Login with Google</Text>
      <View style={styles.buttonContainer}>
        <Button title={loading ? 'Signing in...' : 'Sign in with Google'} onPress={handleSignIn} disabled={loading} />
      </View>
      {!!error && <Text style={styles.error}>{error}</Text>}
    </View>
  );
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
    alignItems: 'center',
    justifyContent: 'center',
    padding: 16,
  },
  title: {
    fontSize: 24,
    fontWeight: '600',
    marginBottom: 16,
  },
  buttonContainer: {
    alignSelf: 'stretch',
  },
  error: {
    color: 'red',
    marginTop: 12,
    textAlign: 'center',
  },
});
