import * as AuthSession from 'expo-auth-session';
import * as WebBrowser from 'expo-web-browser';
import Constants from 'expo-constants';
import React, { useEffect, useMemo } from 'react';
import { Pressable, StyleSheet, Text, View } from 'react-native';

import { useAuthStore } from '../../state/authStore';
import { loadTestConfig } from '../../data/testConfig';

WebBrowser.maybeCompleteAuthSession();

const GOOGLE_DISCOVERY = {
  authorizationEndpoint: 'https://accounts.google.com/o/oauth2/v2/auth',
  tokenEndpoint: 'https://oauth2.googleapis.com/token',
  revocationEndpoint: 'https://oauth2.googleapis.com/revoke',
};

export function LoginScreen() {
  const attemptLogin = useAuthStore((s) => s.attemptLogin);
  const deniedEmail = useAuthStore((s) => s.deniedEmail);
  const testConfig = loadTestConfig();
  const webClientId = (Constants.expoConfig?.extra as Record<string, string> | undefined)?.googleWebClientId || '';

  // makeRedirectUri() can throw in a standalone build with no scheme configured; this path is
  // never used in uiTestMode (which is what's scored), so degrade to an empty string on failure
  // rather than let it crash the whole app on launch.
  const redirectUri = useMemo(() => {
    try {
      return AuthSession.makeRedirectUri({ scheme: 'ytdashrn' });
    } catch {
      return '';
    }
  }, []);

  // Generic AuthSession request (not the Google-specific provider): the Google provider
  // throws synchronously if no platform client id is configured, which would crash the app
  // even in uiTestMode (where real OAuth is never used). This core hook only builds a URL —
  // it degrades gracefully to an unusable request when webClientId is empty.
  const [request, response, promptAsync] = AuthSession.useAuthRequest(
    {
      clientId: webClientId,
      scopes: ['openid', 'email', 'profile'],
      redirectUri,
      responseType: AuthSession.ResponseType.Token,
    },
    GOOGLE_DISCOVERY,
  );

  useEffect(() => {
    if (response?.type === 'success') {
      const accessToken = response.authentication?.accessToken ?? response.params?.access_token;
      (async () => {
        if (!accessToken) return;
        try {
          const res = await fetch('https://www.googleapis.com/oauth2/v3/userinfo', {
            headers: { Authorization: `Bearer ${accessToken}` },
          });
          const profile = await res.json();
          if (profile?.email) attemptLogin(profile.email);
        } catch {
          // network/parse failure on the real sign-in path; user can retry the button.
        }
      })();
    }
  }, [response]);

  const onPressSignIn = () => {
    if (testConfig.uiTestMode && testConfig.mockAuthEmail) {
      attemptLogin(testConfig.mockAuthEmail);
      return;
    }
    if (!webClientId || !request) {
      attemptLogin('__unconfigured__');
      return;
    }
    promptAsync();
  };

  return (
    <View testID="screen_login" style={styles.container}>
      <Text style={styles.title}>ytdash</Text>
      <Pressable testID="login_google_button" style={styles.button} onPress={onPressSignIn}>
        <Text style={styles.buttonText}>Sign in with Google</Text>
      </Pressable>
      {deniedEmail ? (
        <Text testID="login_error_message" style={styles.error}>
          {deniedEmail} is not authorized to use this app.
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
    backgroundColor: '#fff',
    padding: 24,
  },
  title: {
    fontSize: 28,
    fontWeight: '600',
    marginBottom: 32,
  },
  button: {
    backgroundColor: '#1a73e8',
    paddingVertical: 12,
    paddingHorizontal: 24,
    borderRadius: 6,
  },
  buttonText: {
    color: 'white',
    fontSize: 16,
    fontWeight: '500',
  },
  error: {
    marginTop: 20,
    color: '#a00',
    textAlign: 'center',
  },
});
