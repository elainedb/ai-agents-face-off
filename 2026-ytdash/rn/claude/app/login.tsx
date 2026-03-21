import React, { useEffect, useState } from 'react';
import {
  View,
  Text,
  TouchableOpacity,
  StyleSheet,
  ActivityIndicator,
  Platform,
} from 'react-native';
import {
  GoogleSignin,
  statusCodes,
} from '@react-native-google-signin/google-signin';
import { useRouter } from 'expo-router';

let authorizedEmails: string[] = [
  'user1@example.com',
  'user3@example.com',
  'user2@example.com',
];

try {
  const config = require('../config.json');
  if (config.authorizedEmails) {
    authorizedEmails = config.authorizedEmails;
  }
} catch {
  // Use hardcoded fallback
}

export default function LoginScreen() {
  const router = useRouter();
  const [error, setError] = useState<string | null>(null);
  const [isSigningIn, setIsSigningIn] = useState(false);

  useEffect(() => {
    GoogleSignin.configure({
      scopes: ['openid', 'profile', 'email'],
    });

    checkExistingSignIn();
  }, []);

  const checkExistingSignIn = async () => {
    try {
      const currentUser = await GoogleSignin.getCurrentUser();
      console.log('Current sign-in status:', currentUser ? 'signed in' : 'not signed in');
    } catch (err) {
      console.log('Error checking sign-in status:', err);
    }
  };

  const handleSignIn = async () => {
    if (isSigningIn) return;

    setIsSigningIn(true);
    setError(null);

    try {
      try {
        await GoogleSignin.hasPlayServices();
      } catch {
        console.log('Play Services check failed, continuing anyway');
      }

      const userInfo = await GoogleSignin.signIn();
      const email =
        (userInfo as any).data?.user?.email ||
        (userInfo as any).user?.email;

      if (email && authorizedEmails.includes(email)) {
        router.replace('/main');
      } else {
        setError('Access denied. Your email is not authorized.');
        await GoogleSignin.signOut();
      }
    } catch (err: any) {
      if (err.code === statusCodes.SIGN_IN_CANCELLED) {
        setError('Sign-in was cancelled.');
      } else if (err.code === statusCodes.IN_PROGRESS) {
        setError('Sign-in is already in progress.');
      } else if (err.code === statusCodes.PLAY_SERVICES_NOT_AVAILABLE) {
        setError('Google Play Services is not available.');
      } else {
        setError(`Sign-in failed: ${err.message || 'Unknown error'}`);
      }
    } finally {
      setIsSigningIn(false);
    }
  };

  return (
    <View style={styles.container}>
      <Text style={styles.title}>Login with Google</Text>

      <TouchableOpacity
        style={[styles.button, isSigningIn && styles.buttonDisabled]}
        onPress={handleSignIn}
        disabled={isSigningIn}
      >
        {isSigningIn ? (
          <ActivityIndicator color="#fff" />
        ) : (
          <Text style={styles.buttonText}>Sign in with Google</Text>
        )}
      </TouchableOpacity>

      {error && <Text style={styles.errorText}>{error}</Text>}

      <Text style={styles.debugText}>
        Package: {Platform.OS === 'android' ? 'dev.elainedb.rn_claude' : 'dev.elainedb.rn-claude'}
        {'\n'}Config: {authorizedEmails.length} authorized emails
      </Text>
    </View>
  );
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
    justifyContent: 'center',
    alignItems: 'center',
    padding: 20,
    backgroundColor: '#fff',
  },
  title: {
    fontSize: 24,
    fontWeight: 'bold',
    marginBottom: 40,
    color: '#333',
  },
  button: {
    backgroundColor: '#4285F4',
    paddingHorizontal: 24,
    paddingVertical: 14,
    borderRadius: 8,
    minWidth: 220,
    alignItems: 'center',
  },
  buttonDisabled: {
    opacity: 0.7,
  },
  buttonText: {
    color: '#fff',
    fontSize: 16,
    fontWeight: '600',
  },
  errorText: {
    color: '#d32f2f',
    marginTop: 16,
    textAlign: 'center',
    fontSize: 14,
  },
  debugText: {
    position: 'absolute',
    bottom: 40,
    color: '#999',
    fontSize: 12,
    textAlign: 'center',
  },
});
