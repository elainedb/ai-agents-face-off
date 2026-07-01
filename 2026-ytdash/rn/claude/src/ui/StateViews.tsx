import React from 'react';
import { ActivityIndicator, Pressable, StyleSheet, Text, View } from 'react-native';

// Blocking loading state (constitution §6 / selector `loading_indicator`).
export function LoadingView() {
  return (
    <View testID="loading_indicator" style={styles.center}>
      <ActivityIndicator size="large" color="#c00" />
      <Text style={styles.muted}>Loading…</Text>
    </View>
  );
}

// Blocking error state with a retry affordance (constitution §6).
export function ErrorView({ message, onRetry }: { message: string | null; onRetry: () => void }) {
  return (
    <View testID="error_view" style={styles.center}>
      <Text style={styles.errorText}>{message ?? 'Something went wrong.'}</Text>
      <Pressable testID="error_retry_button" style={styles.button} onPress={onRetry}>
        <Text style={styles.buttonText}>Retry</Text>
      </Pressable>
    </View>
  );
}

export function EmptyView({ message }: { message?: string }) {
  return (
    <View style={styles.center}>
      <Text style={styles.muted}>{message ?? 'No videos to show.'}</Text>
    </View>
  );
}

const styles = StyleSheet.create({
  center: { flex: 1, alignItems: 'center', justifyContent: 'center', padding: 24, gap: 12 },
  muted: { color: '#666', fontSize: 16 },
  errorText: { color: '#b00020', fontSize: 16, textAlign: 'center' },
  button: { backgroundColor: '#c00', paddingHorizontal: 24, paddingVertical: 12, borderRadius: 8 },
  buttonText: { color: '#fff', fontWeight: '600', fontSize: 16 },
});
