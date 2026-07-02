import { ActivityIndicator, StyleSheet, Text, View } from 'react-native';

export function LoadingView({ label = 'Loading…' }: { label?: string }) {
  return (
    <View testID="loading_indicator" style={styles.container}>
      <ActivityIndicator size="large" />
      <Text style={styles.label}>{label}</Text>
    </View>
  );
}

const styles = StyleSheet.create({
  container: { flex: 1, alignItems: 'center', justifyContent: 'center', gap: 12 },
  label: { fontSize: 14, color: '#666' },
});
