import React from 'react';
import { Pressable, StyleSheet, Text, View } from 'react-native';

type Props = {
  message: string;
  onRetry: () => void;
};

export function ErrorView({ message, onRetry }: Props) {
  return (
    <View testID="error_view" style={styles.container}>
      <Text style={styles.message}>{message}</Text>
      <Pressable testID="error_retry_button" style={styles.button} onPress={onRetry}>
        <Text style={styles.buttonText}>Retry</Text>
      </Pressable>
    </View>
  );
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
    alignItems: 'center',
    justifyContent: 'center',
    padding: 24,
    gap: 16,
  },
  message: {
    textAlign: 'center',
    color: '#7f1d1d',
  },
  button: {
    backgroundColor: '#1f2937',
    paddingHorizontal: 20,
    paddingVertical: 10,
    borderRadius: 8,
  },
  buttonText: {
    color: 'white',
    fontWeight: '600',
  },
});
