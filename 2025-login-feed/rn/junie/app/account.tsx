import React, { useEffect, useState, useCallback } from 'react';
import { View, Text, Button, StyleSheet } from 'react-native';
import { GoogleSignin } from '@react-native-google-signin/google-signin';
import { useFocusEffect, useRouter } from 'expo-router';

function log(tag: string, message: string, extra?: any) {
  const ts = new Date().toISOString();
  if (extra !== undefined) {
    console.log(`[Account ${tag}] ${ts} - ${message}`, extra);
  } else {
    console.log(`[Account ${tag}] ${ts} - ${message}`);
  }
}

export default function AccountScreen() {
  const router = useRouter();
  const [email, setEmail] = useState<string>('');
  const [error, setError] = useState<string | null>(null);
  const [loading, setLoading] = useState(false);

  useEffect(() => {
    let mounted = true;
    (async () => {
      try {
        log('INIT', 'Reading current user on mount');
        const current = await GoogleSignin.getCurrentUser();
        if (mounted) {
          setEmail(current?.user?.email ?? '');
          log('STATE', 'Set email on mount', { email: current?.user?.email });
        }
      } catch (e: any) {
        if (mounted) setError(e?.message || 'Failed to retrieve current user.');
        log('ERROR', 'Failed to get current user on mount', e);
      }
    })();
    return () => {
      mounted = false;
    };
  }, []);

  // Refresh user info whenever this screen is focused to avoid stale state after logout/login cycles
  useFocusEffect(
    useCallback(() => {
      let active = true;
      (async () => {
        try {
          log('FOCUS', 'Screen focused, refreshing current user');
          const current = await GoogleSignin.getCurrentUser();
          if (active) {
            setEmail(current?.user?.email ?? '');
            log('STATE', 'Updated email on focus', { email: current?.user?.email });
          }
        } catch (e: any) {
          if (active) setError(e?.message || 'Failed to retrieve current user.');
          log('ERROR', 'Failed to get current user on focus', e);
        }
      })();
      return () => {
        active = false;
      };
    }, [])
  );

  const handleLogout = useCallback(async () => {
    setError(null);
    setLoading(true);
    try {
      log('ACTION', 'Logout pressed');
      // Revoke and sign out to fully disconnect
      try { log('RESET', 'Revoking access'); await GoogleSignin.revokeAccess(); } catch (e) { log('RESET', 'Revoke failed (ignored)', e); }
      try { log('RESET', 'Signing out'); await GoogleSignin.signOut(); } catch (e) { log('RESET', 'Sign out failed (ignored)', e); }
      // Clear local state so the UI reflects the logged-out state
      setEmail('');
      log('STATE', 'Cleared email after logout');
      // Stay on this screen so the button label can change to "Login"
    } catch (e: any) {
      setError(e?.message || 'Failed to log out.');
      log('ERROR', 'Logout flow error', e);
    } finally {
      setLoading(false);
      log('FLOW', 'Logout finished');
    }
  }, []);

  const handleLogin = useCallback(() => {
    log('NAV', 'Navigating to / (login)');
    // Replace the current screen with the login to avoid nested navigator glitches
    router.replace('/');
  }, [router]);

  const isSignedIn = !!email;
  const buttonTitle = loading ? (isSignedIn ? 'Logging out...' : 'Logging in...') : (isSignedIn ? 'Logout' : 'Login');
  const onPress = isSignedIn ? handleLogout : handleLogin;

  return (
    <View style={styles.container}>
      <Text style={styles.title}>Account</Text>
      {isSignedIn ? (
        <Text style={styles.subtitle}>Signed in as: {email}</Text>
      ) : (
        <Text style={styles.subtitle}>You are not signed in.</Text>
      )}
      <View style={styles.buttonContainer}>
        <Button title={buttonTitle} onPress={onPress} disabled={loading} />
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
    marginBottom: 8,
  },
  subtitle: {
    fontSize: 14,
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