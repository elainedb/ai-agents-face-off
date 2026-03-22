import { useEffect, useState } from 'react';
import {
  ActivityIndicator,
  Platform,
  Pressable,
  StyleSheet,
  Text,
  View,
} from 'react-native';
import { SafeAreaView } from 'react-native-safe-area-context';
import { useRouter } from 'expo-router';
import {
  GoogleSignin,
  isErrorWithCode,
  statusCodes,
} from '@react-native-google-signin/google-signin';

const FALLBACK_AUTHORIZED_EMAILS = [
  'user1@example.com',
  'user3@example.com',
  'user2@example.com',
];

type ConfigJson = {
  authorizedEmails?: string[];
};

let configJson: ConfigJson | null = null;

try {
  configJson = require('@/config.json') as ConfigJson;
} catch {
  configJson = null;
}

const authorizedEmails = (configJson?.authorizedEmails ?? FALLBACK_AUTHORIZED_EMAILS).map((email) =>
  email.toLowerCase()
);

export default function LoginScreen() {
  const router = useRouter();
  const [isLoading, setIsLoading] = useState(false);
  const [errorMessage, setErrorMessage] = useState('');
  const [debugMessage, setDebugMessage] = useState('Initializing Google Sign-In...');

  useEffect(() => {
    GoogleSignin.configure({
      scopes: ['openid', 'profile', 'email'],
    });

    let isMounted = true;

    async function checkExistingSession() {
      try {
        const hasPreviousSignIn = await GoogleSignin.hasPreviousSignIn();
        if (!isMounted) {
          return;
        }

        setDebugMessage(
          `Android package: dev.elainedb.rn_codex | config.json: ${
            configJson ? 'loaded' : 'fallback'
          } | previous sign-in: ${hasPreviousSignIn ? 'yes' : 'no'}`
        );
      } catch (error) {
        if (!isMounted) {
          return;
        }

        setDebugMessage(
          `Android package: dev.elainedb.rn_codex | config.json: ${
            configJson ? 'loaded' : 'fallback'
          } | status check failed`
        );
        console.warn('Failed to check existing Google session', error);
      }
    }

    void checkExistingSession();

    return () => {
      isMounted = false;
    };
  }, []);

  async function handleSignIn() {
    if (Platform.OS !== 'android') {
      setErrorMessage('This build is configured for Android only.');
      return;
    }

    setIsLoading(true);
    setErrorMessage('');

    try {
      try {
        await GoogleSignin.hasPlayServices({
          showPlayServicesUpdateDialog: true,
        });
      } catch (playServicesError) {
        console.warn('Play Services check failed', playServicesError);
      }

      const userInfo = await GoogleSignin.signIn();
      const legacyUserInfo = userInfo as {
        user?: {
          email?: string | null;
        };
      };
      const email =
        userInfo.data?.user?.email?.toLowerCase() ?? legacyUserInfo.user?.email?.toLowerCase() ?? '';

      if (!email) {
        setErrorMessage('Unable to read the Google account email.');
        return;
      }

      if (!authorizedEmails.includes(email)) {
        setErrorMessage('Access denied');
        await GoogleSignin.signOut();
        return;
      }

      router.replace('/main');
    } catch (error) {
      if (isErrorWithCode(error)) {
        switch (error.code) {
          case statusCodes.SIGN_IN_CANCELLED:
            setErrorMessage('Sign-in cancelled.');
            break;
          case statusCodes.IN_PROGRESS:
            setErrorMessage('Sign-in already in progress.');
            break;
          case statusCodes.PLAY_SERVICES_NOT_AVAILABLE:
            setErrorMessage('Google Play Services are unavailable.');
            break;
          default:
            setErrorMessage(error.message || 'Google sign-in failed.');
            break;
        }
      } else {
        setErrorMessage('Unknown sign-in error.');
      }
    } finally {
      setIsLoading(false);
    }
  }

  return (
    <SafeAreaView style={styles.safeArea}>
      <View style={styles.container}>
        <View style={styles.card}>
          <Text style={styles.title}>Login with Google</Text>
          <Pressable
            accessibilityRole="button"
            onPress={() => void handleSignIn()}
            disabled={isLoading}
            style={({ pressed }) => [
              styles.signInButton,
              isLoading && styles.disabledButton,
              pressed && !isLoading ? styles.pressedButton : null,
            ]}>
            {isLoading ? (
              <ActivityIndicator color="#ffffff" />
            ) : (
              <Text style={styles.signInButtonText}>Sign in with Google</Text>
            )}
          </Pressable>
          {errorMessage ? <Text style={styles.errorText}>{errorMessage}</Text> : null}
        </View>
        <Text style={styles.debugText}>{debugMessage}</Text>
      </View>
    </SafeAreaView>
  );
}

const styles = StyleSheet.create({
  safeArea: {
    flex: 1,
    backgroundColor: '#f4f7fb',
  },
  container: {
    flex: 1,
    justifyContent: 'space-between',
    paddingHorizontal: 24,
    paddingVertical: 32,
  },
  card: {
    marginTop: 72,
    borderRadius: 24,
    backgroundColor: '#ffffff',
    padding: 24,
    shadowColor: '#001b3d',
    shadowOpacity: 0.08,
    shadowRadius: 18,
    shadowOffset: { width: 0, height: 10 },
    elevation: 4,
  },
  title: {
    fontSize: 28,
    fontWeight: '700',
    color: '#101828',
    marginBottom: 24,
  },
  signInButton: {
    minHeight: 52,
    borderRadius: 14,
    backgroundColor: '#4285F4',
    alignItems: 'center',
    justifyContent: 'center',
    paddingHorizontal: 20,
  },
  pressedButton: {
    opacity: 0.92,
  },
  disabledButton: {
    opacity: 0.7,
  },
  signInButtonText: {
    color: '#ffffff',
    fontSize: 16,
    fontWeight: '700',
  },
  errorText: {
    marginTop: 16,
    color: '#d32f2f',
    fontSize: 14,
  },
  debugText: {
    color: '#667085',
    fontSize: 12,
    lineHeight: 18,
  },
});
