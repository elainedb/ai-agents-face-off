import React from 'react';
import { Pressable, StyleSheet, Text, View } from 'react-native';
import { useExternalStore } from '../state/externalStore';

// App-root overlay that surfaces the "open in YouTube" outcome (constitution §3 / §4):
//  - captureExternalLinks=true  -> external_open_url whose text is the exact target URL
//  - a real launch that fails   -> external_open_error (never a crash / silent no-op)
export function ExternalBanner() {
  const { capturedUrl, error, reset } = useExternalStore();
  if (!capturedUrl && !error) return null;
  return (
    <View style={styles.wrap} pointerEvents="box-none">
      {capturedUrl ? (
        <View style={styles.banner}>
          <Text style={styles.label}>Opening in YouTube:</Text>
          <Text testID="external_open_url" style={styles.url}>
            {capturedUrl}
          </Text>
          <Pressable testID="external_open_dismiss" onPress={reset} style={styles.dismiss}>
            <Text style={styles.dismissText}>Dismiss</Text>
          </Pressable>
        </View>
      ) : null}
      {error ? (
        <View style={[styles.banner, styles.errorBanner]}>
          <Text testID="external_open_error" style={styles.url}>
            Could not open YouTube. Please try again.
          </Text>
          <Pressable testID="external_open_dismiss" onPress={reset} style={styles.dismiss}>
            <Text style={styles.dismissText}>Dismiss</Text>
          </Pressable>
        </View>
      ) : null}
    </View>
  );
}

const styles = StyleSheet.create({
  wrap: { position: 'absolute', top: 0, left: 0, right: 0, zIndex: 1000 },
  banner: { backgroundColor: '#1f2937', padding: 12, paddingTop: 40 },
  errorBanner: { backgroundColor: '#7f1d1d' },
  label: { color: '#9ca3af', fontSize: 12 },
  url: { color: '#ffffff', fontSize: 14, marginTop: 2 },
  dismiss: { marginTop: 8, alignSelf: 'flex-start' },
  dismissText: { color: '#93c5fd', fontSize: 13 },
});
