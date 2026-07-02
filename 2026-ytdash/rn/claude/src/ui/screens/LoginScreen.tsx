import { Pressable, StyleSheet, Text, View } from 'react-native';

import { useAuthStore } from '../../state/authStore';

export function LoginScreen() {
  const signIn = useAuthStore((s) => s.signIn);
  const errorMessage = useAuthStore((s) => s.errorMessage);

  return (
    <View testID="screen_login" style={styles.container}>
      <Text style={styles.title}>ytdash</Text>
      <Text style={styles.subtitle}>Sign in to see your channels&apos; latest videos.</Text>
      <Pressable testID="login_google_button" onPress={signIn} style={styles.button}>
        <Text style={styles.buttonText}>Sign in with Google</Text>
      </Pressable>
      {errorMessage ? (
        <Text testID="login_error_message" style={styles.error}>
          {errorMessage}
        </Text>
      ) : null}
    </View>
  );
}

const styles = StyleSheet.create({
  container: { flex: 1, alignItems: 'center', justifyContent: 'center', padding: 24, gap: 16, backgroundColor: '#fff' },
  title: { fontSize: 28, fontWeight: '700' },
  subtitle: { fontSize: 14, color: '#666', textAlign: 'center', marginBottom: 8 },
  button: { backgroundColor: '#1a73e8', paddingVertical: 12, paddingHorizontal: 28, borderRadius: 8 },
  buttonText: { color: '#fff', fontWeight: '600', fontSize: 15 },
  error: { color: '#b00020', fontSize: 13, textAlign: 'center', marginTop: 12 },
});
