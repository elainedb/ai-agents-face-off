import React from 'react';
import { View, Text, Pressable, StyleSheet } from 'react-native';
import { IDS } from './selectors';
import { useExternalStore } from '../state/stores';

/**
 * App-root banner shared by the list and the map sheet. In capture mode it shows the exact target
 * URL (external_open_url); if a real launch fails it shows external_open_error (constitution §4).
 */
export default function ExternalBanner() {
  const capturedUrl = useExternalStore((s) => s.capturedUrl);
  const openError = useExternalStore((s) => s.openError);
  const clear = useExternalStore((s) => s.clear);

  if (!capturedUrl && !openError) return null;

  return (
    <View style={styles.wrap} pointerEvents="box-none">
      <View style={styles.banner}>
        {capturedUrl ? (
          <Text testID={IDS.externalOpenUrl} accessibilityLabel={IDS.externalOpenUrl} style={styles.url}>
            {capturedUrl}
          </Text>
        ) : null}
        {openError ? (
          <Text testID={IDS.externalOpenError} accessibilityLabel={IDS.externalOpenError} style={styles.err}>
            {openError}
          </Text>
        ) : null}
        <Pressable style={styles.dismiss} onPress={clear}>
          <Text style={styles.dismissText}>Dismiss</Text>
        </Pressable>
      </View>
    </View>
  );
}

const styles = StyleSheet.create({
  wrap: { position: 'absolute', top: 40, left: 0, right: 0, alignItems: 'center', zIndex: 1000 },
  banner: {
    backgroundColor: '#111',
    marginHorizontal: 12,
    paddingVertical: 12,
    paddingHorizontal: 16,
    borderRadius: 8,
    maxWidth: '96%',
  },
  url: { color: '#8fd0ff', fontSize: 13 },
  err: { color: '#ff8f8f', fontSize: 13, fontWeight: '600' },
  dismiss: { marginTop: 8, alignSelf: 'flex-end' },
  dismissText: { color: '#aaa', fontSize: 12 },
});
