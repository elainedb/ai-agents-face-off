import { Pressable, StyleSheet, Text, View } from 'react-native';

export function ErrorView({ message, onRetry }: { message: string; onRetry: () => void }) {
  return (
    <View testID="error_view" style={styles.container}>
      <Text style={styles.message}>{message}</Text>
      <Pressable testID="error_retry_button" onPress={onRetry} style={styles.button}>
        <Text style={styles.buttonText}>Retry</Text>
      </Pressable>
    </View>
  );
}

const styles = StyleSheet.create({
  container: { flex: 1, alignItems: 'center', justifyContent: 'center', padding: 24, gap: 16 },
  message: { fontSize: 15, color: '#b00020', textAlign: 'center' },
  button: { backgroundColor: '#1a73e8', paddingVertical: 10, paddingHorizontal: 24, borderRadius: 6 },
  buttonText: { color: '#fff', fontWeight: '600' },
});
