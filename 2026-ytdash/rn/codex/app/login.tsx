import { useEffect, useState } from 'react';
import {
  ActivityIndicator,
  Platform,
  Pressable,
  SafeAreaView,
  StyleSheet,
  Text,
  View,
} from 'react-native';
import { GoogleSignin, isErrorWithCode, statusCodes } from '@react-native-google-signin/google-signin';
import { router } from 'expo-router';

import appConfig from '@/app.json';
import config from '@/config.json';

const fallbackAuthorizedEmails = [
  'user1@example.com',
  'user3@example.com',
  'user2@example.com',
];

const authorizedEmails =
  Array.isArray(config.authorizedEmails) && config.authorizedEmails.length > 0
    ? config.authorizedEmails
    : fallbackAuthorizedEmails;

const packageName = appConfig.expo.android?.package ?? 'unknown';

export default function LoginScreen() {
  const [loading, setLoading] = useState(false);
  const [errorMessage, setErrorMessage] = useState('');
  const [debugStatus, setDebugStatus] = useState('Config loaded');

  useEffect(() => {
    GoogleSignin.configure({
      scopes: ['openid', 'profile', 'email'],
    });

    const currentUser = GoogleSignin.getCurrentUser();
    Promise.resolve(currentUser)
      .then((signedInUser) => {
        setDebugStatus((current) => `${current} | signedIn=${String(Boolean(signedInUser))}`);
      })
      .catch(() => {
        setDebugStatus((current) => `${current} | signedIn=unknown`);
      });
  }, []);

  const handleSignIn = async () => {
    setLoading(true);
    setErrorMessage('');

    try {
      try {
        await GoogleSignin.hasPlayServices({ showPlayServicesUpdateDialog: true });
      } catch {
        setDebugStatus((current) => `${current} | playServicesCheckFailed`);
      }

      const userInfo = await GoogleSignin.signIn();
      const legacyUserInfo = userInfo as { user?: { email?: string } };
      const email = userInfo.data?.user?.email ?? legacyUserInfo.user?.email ?? '';

      if (authorizedEmails.includes(email.toLowerCase())) {
        router.replace('/main');
        return;
      }

      setErrorMessage('Access denied');
      await GoogleSignin.signOut();
    } catch (error) {
      if (isErrorWithCode(error)) {
        switch (error.code) {
          case statusCodes.SIGN_IN_CANCELLED:
            setErrorMessage('Sign-in cancelled');
            break;
          case statusCodes.IN_PROGRESS:
            setErrorMessage('Sign-in already in progress');
            break;
          case statusCodes.PLAY_SERVICES_NOT_AVAILABLE:
            setErrorMessage('Google Play Services unavailable');
            break;
          default:
            setErrorMessage('Unable to sign in');
            break;
        }
      } else {
        setErrorMessage('Unable to sign in');
      }
    } finally {
      setLoading(false);
    }
  };

  const configStatus = `Package: ${packageName} | Emails: ${authorizedEmails.length} | Platform: ${Platform.OS}`;

  return (
    <SafeAreaView style={styles.safeArea}>
      <View style={styles.container}>
        <Text style={styles.title}>Login with Google</Text>
        <Pressable
          accessibilityRole="button"
          disabled={loading}
          onPress={handleSignIn}
          style={({ pressed }) => [
            styles.button,
            (pressed || loading) && styles.buttonPressed,
          ]}>
          {loading ? <ActivityIndicator color="#ffffff" /> : <Text style={styles.buttonText}>Sign in with Google</Text>}
        </Pressable>
        {errorMessage ? <Text style={styles.error}>{errorMessage}</Text> : null}
        <View style={styles.debugContainer}>
          <Text style={styles.debugText}>{configStatus}</Text>
          <Text style={styles.debugText}>{debugStatus}</Text>
        </View>
      </View>
    </SafeAreaView>
  );
}

const styles = StyleSheet.create({
  safeArea: {
    flex: 1,
    backgroundColor: '#f7f9fc',
  },
  container: {
    flex: 1,
    justifyContent: 'center',
    paddingHorizontal: 24,
  },
  title: {
    fontSize: 28,
    fontWeight: '700',
    color: '#14213d',
    marginBottom: 24,
    textAlign: 'center',
  },
  button: {
    alignItems: 'center',
    backgroundColor: '#4285F4',
    borderRadius: 14,
    minHeight: 54,
    justifyContent: 'center',
    paddingHorizontal: 20,
  },
  buttonPressed: {
    opacity: 0.8,
  },
  buttonText: {
    color: '#ffffff',
    fontSize: 16,
    fontWeight: '600',
  },
  error: {
    color: '#d32f2f',
    fontSize: 14,
    marginTop: 16,
    textAlign: 'center',
  },
  debugContainer: {
    marginTop: 32,
  },
  debugText: {
    color: '#5c677d',
    fontSize: 12,
    textAlign: 'center',
  },
});
