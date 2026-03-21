import { useEffect, useState } from 'react';
import {
  View,
  Text,
  TouchableOpacity,
  ActivityIndicator,
  StyleSheet,
} from 'react-native';
import {
  GoogleSignin,
  statusCodes,
} from '@react-native-google-signin/google-signin';
import { useRouter } from 'expo-router';

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

    const checkCurrentUser = async () => {
      try {
        const currentUser = GoogleSignin.getCurrentUser();
        console.log('Current user:', currentUser ? 'signed in' : 'not signed in');
      } catch (e) {
        console.log('Error checking current user:', e);
      }
    };
    checkCurrentUser();
  }, []);

  const handleSignIn = async () => {
    setError(null);
    setIsSigningIn(true);

    try {
      try {
        await GoogleSignin.hasPlayServices();
      } catch (e) {
        console.log('Play Services check failed:', e);
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
        Package: dev.elainedb.rn_claude{'\n'}
        Config: {authorizedEmails.length > 0 ? 'Loaded' : 'Missing'}
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
    paddingHorizontal: 30,
    paddingVertical: 15,
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
    marginTop: 20,
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
