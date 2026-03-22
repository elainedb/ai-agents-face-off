import { useEffect, useState } from 'react';
import {
  ActivityIndicator,
  Platform,
  StyleSheet,
  Text,
  TouchableOpacity,
  View,
} from 'react-native';
import {
  GoogleSignin,
  isErrorWithCode,
  isSuccessResponse,
  statusCodes,
} from '@react-native-google-signin/google-signin';
import { useRouter } from 'expo-router';

const fallbackAuthorizedEmails = [
  'user1@example.com',
  'user3@example.com',
  'user2@example.com',
];

type LocalConfig = {
  authorizedEmails?: string[];
};

function loadAuthorizedEmails(): string[] {
  try {
    const config = require('../config.json') as LocalConfig;
    if (Array.isArray(config.authorizedEmails) && config.authorizedEmails.length > 0) {
      return config.authorizedEmails;
    }
  } catch {
    return fallbackAuthorizedEmails;
  }

  return fallbackAuthorizedEmails;
}

const authorizedEmails = loadAuthorizedEmails();

export default function LoginScreen() {
  const router = useRouter();
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState('');
  const [configStatus, setConfigStatus] = useState('Checking configuration...');

  useEffect(() => {
    GoogleSignin.configure({
      scopes: ['openid', 'profile', 'email'],
    });

    setConfigStatus(`Android config loaded (${authorizedEmails.length} authorized emails)`);

    try {
      if (GoogleSignin.hasPreviousSignIn()) {
        console.log('Existing Google session detected', GoogleSignin.getCurrentUser()?.user?.email);
      }
    } catch (signInError: unknown) {
      console.log('Unable to check sign-in state', signInError);
    }
  }, []);

  const handleSignIn = async () => {
    setLoading(true);
    setError('');

    try {
      try {
        await GoogleSignin.hasPlayServices({ showPlayServicesUpdateDialog: true });
      } catch (playServicesError) {
        console.log('Play Services check failed', playServicesError);
      }

      const userInfo = await GoogleSignin.signIn();
      const email = isSuccessResponse(userInfo) ? userInfo.data.user.email : '';

      if (!email) {
        setError('Unable to read the selected Google account email.');
        await GoogleSignin.signOut().catch(() => undefined);
        return;
      }

      if (!authorizedEmails.includes(email.toLowerCase())) {
        setError('Access denied');
        await GoogleSignin.signOut().catch(() => undefined);
        return;
      }

      router.replace('/main');
    } catch (signInError) {
      if (isErrorWithCode(signInError)) {
        switch (signInError.code) {
          case statusCodes.SIGN_IN_CANCELLED:
            setError('Sign-in cancelled.');
            break;
          case statusCodes.IN_PROGRESS:
            setError('Sign-in already in progress.');
            break;
          case statusCodes.PLAY_SERVICES_NOT_AVAILABLE:
            setError('Google Play Services are not available on this device.');
            break;
          default:
            setError(signInError.message || 'Google sign-in failed.');
        }
      } else {
        setError('An unknown sign-in error occurred.');
      }
    } finally {
      setLoading(false);
    }
  };

  return (
    <View style={styles.container}>
      <View style={styles.card}>
        <Text style={styles.title}>Login with Google</Text>
        <TouchableOpacity
          accessibilityRole="button"
          disabled={loading}
          onPress={handleSignIn}
          style={[styles.button, loading && styles.buttonDisabled]}>
          {loading ? <ActivityIndicator color="#ffffff" /> : <Text style={styles.buttonText}>Sign in with Google</Text>}
        </TouchableOpacity>
        {error ? <Text style={styles.errorText}>{error}</Text> : null}
      </View>

      <View style={styles.debugBlock}>
        <Text style={styles.debugText}>Platform: {Platform.OS}</Text>
        <Text style={styles.debugText}>Package: dev.elainedb.rn_codex</Text>
        <Text style={styles.debugText}>{configStatus}</Text>
      </View>
    </View>
  );
}

const styles = StyleSheet.create({
  container: {
    alignItems: 'center',
    backgroundColor: '#f3f6fb',
    flex: 1,
    justifyContent: 'center',
    padding: 24,
  },
  card: {
    backgroundColor: '#ffffff',
    borderRadius: 20,
    elevation: 3,
    maxWidth: 420,
    padding: 24,
    shadowColor: '#000000',
    shadowOffset: { width: 0, height: 8 },
    shadowOpacity: 0.08,
    shadowRadius: 16,
    width: '100%',
  },
  title: {
    color: '#111827',
    fontSize: 28,
    fontWeight: '700',
    marginBottom: 24,
    textAlign: 'center',
  },
  button: {
    alignItems: 'center',
    backgroundColor: '#4285F4',
    borderRadius: 12,
    minHeight: 52,
    justifyContent: 'center',
    paddingHorizontal: 16,
  },
  buttonDisabled: {
    opacity: 0.7,
  },
  buttonText: {
    color: '#ffffff',
    fontSize: 16,
    fontWeight: '600',
  },
  errorText: {
    color: '#d32f2f',
    fontSize: 14,
    marginTop: 16,
    textAlign: 'center',
  },
  debugBlock: {
    marginTop: 32,
  },
  debugText: {
    color: '#6b7280',
    fontSize: 13,
    textAlign: 'center',
  },
});
