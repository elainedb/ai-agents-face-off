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

let GoogleSignin: any = null;
let statusCodes: any = {};
try {
  const gsi = require('@react-native-google-signin/google-signin');
  GoogleSignin = gsi.GoogleSignin;
  statusCodes = gsi.statusCodes;
} catch (e) {
  console.warn('Google Sign-In native module not available:', e);
}

let authorizedEmails: string[] = [];
try {
  const config = require('@/config.json');
  authorizedEmails = config.authorizedEmails || [];
} catch {
  authorizedEmails = ['user1@example.com', 'user2@example.com'];
}

export default function LoginScreen() {
  const router = useRouter();
  const [error, setError] = useState<string | null>(null);
  const [loading, setLoading] = useState(false);

  useEffect(() => {
    if (!GoogleSignin) return;

    GoogleSignin.configure({
      scopes: ['openid', 'profile', 'email'],
    });

    // Check if already signed in
    const checkCurrentUser = async () => {
      try {
        const currentUser = await GoogleSignin.getCurrentUser();
        console.log('Current user:', currentUser ? 'signed in' : 'not signed in');
      } catch (e) {
        console.log('Error checking current user:', e);
      }
    };
    checkCurrentUser();
  }, []);

  const handleSignIn = async () => {
    if (!GoogleSignin) {
      setError('Google Sign-In is not available. Please use a dev build.');
      return;
    }

    setError(null);
    setLoading(true);

    try {
      try {
        await GoogleSignin.hasPlayServices();
      } catch (e) {
        console.warn('Play Services check failed:', e);
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
    } catch (e: any) {
      if (e.code === statusCodes.SIGN_IN_CANCELLED) {
        setError('Sign-in was cancelled.');
      } else if (e.code === statusCodes.IN_PROGRESS) {
        setError('Sign-in is already in progress.');
      } else if (e.code === statusCodes.PLAY_SERVICES_NOT_AVAILABLE) {
        setError('Google Play Services is not available.');
      } else {
        setError(`Sign-in failed: ${e.message || 'Unknown error'}`);
      }
    } finally {
      setLoading(false);
    }
  };

  return (
    <View style={styles.container}>
      <Text style={styles.title}>Login with Google</Text>

      <TouchableOpacity
        style={[styles.button, loading && styles.buttonDisabled]}
        onPress={handleSignIn}
        disabled={loading}
      >
        {loading ? (
          <ActivityIndicator color="#fff" />
        ) : (
          <Text style={styles.buttonText}>Sign in with Google</Text>
        )}
      </TouchableOpacity>

      {error && <Text style={styles.errorText}>{error}</Text>}

      <Text style={styles.debugText}>
        Package: {Platform.OS === 'android' ? 'dev.elainedb.rn_claude' : 'dev.elainedb.rn-claude'}
        {'\n'}Config: {authorizedEmails.length} authorized email(s)
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
  },
  button: {
    backgroundColor: '#4285F4',
    paddingHorizontal: 24,
    paddingVertical: 14,
    borderRadius: 8,
    minWidth: 200,
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
  },
  debugText: {
    position: 'absolute',
    bottom: 40,
    color: '#999',
    fontSize: 12,
    textAlign: 'center',
  },
});
