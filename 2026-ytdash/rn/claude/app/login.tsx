import React, { useEffect, useState } from 'react';
import {
  View,
  Text,
  TouchableOpacity,
  StyleSheet,
  ActivityIndicator,
  Platform,
} from 'react-native';
import { useRouter } from 'expo-router';
import {
  GoogleSignin,
  statusCodes,
} from '@react-native-google-signin/google-signin';

let authorizedEmails: string[] = [];
try {
  const config = require('../config.json');
  authorizedEmails = config.authorizedEmails || [];
} catch {
  authorizedEmails = [
    'user1@example.com',
    'user3@example.com',
    'user2@example.com',
  ];
}

export default function LoginScreen() {
  const router = useRouter();
  const [error, setError] = useState<string | null>(null);
  const [isSigningIn, setIsSigningIn] = useState(false);

  useEffect(() => {
    GoogleSignin.configure({
      scopes: ['openid', 'profile', 'email'],
    });

    const checkExistingSignIn = async () => {
      try {
        const currentUser = GoogleSignin.getCurrentUser();
        console.log('Current sign-in status:', currentUser ? 'signed in' : 'not signed in');
      } catch (e) {
        console.log('Error checking sign-in status:', e);
      }
    };
    checkExistingSignIn();
  }, []);

  const handleSignIn = async () => {
    setError(null);
    setIsSigningIn(true);

    try {
      try {
        await GoogleSignin.hasPlayServices();
      } catch (e) {
        console.log('Play Services check failed (non-blocking):', e);
      }

      const userInfo = await GoogleSignin.signIn();
      const email = userInfo.data?.user?.email || (userInfo as any).user?.email;

      if (email && authorizedEmails.includes(email)) {
        router.replace('/main');
      } else {
        setError('Access denied. Your email is not authorized.');
        await GoogleSignin.signOut();
      }
    } catch (e: any) {
      if (e.code === statusCodes.SIGN_IN_CANCELLED) {
        setError('Sign-in was cancelled.');
      } else if (e.code === statusCodes.IN_PROGRESS) {
        setError('Sign-in is already in progress.');
      } else if (e.code === statusCodes.PLAY_SERVICES_NOT_AVAILABLE) {
        setError('Google Play Services is not available.');
      } else {
        setError('An error occurred during sign-in. Please try again.');
        console.error('Sign-in error:', e);
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
