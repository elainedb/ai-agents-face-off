import React from 'react';
import { Pressable, StyleSheet, Text, View } from 'react-native';

import { useStore } from '../state/store';

// Root-level external-open seam, shared by the list (AC-LIST-03) and the map sheet (AC-MAP-03).
// - captureExternalLinks=true → renders `external_open_url` (text = the exact target URL).
// - real launch failure → renders `external_open_error` instead of crashing (AC-LINK-01, §6).
export function ExternalOpenBanner() {
  const url = useStore((s) => s.externalUrl);
  const error = useStore((s) => s.externalError);
  const dismiss = useStore((s) => s.dismissExternal);

  if (!url && !error) return null;

  return (
    <View style={styles.wrap} pointerEvents="box-none">
      <View style={styles.banner}>
        {url ? (
          <Text testID="external_open_url" style={styles.url}>
            {url}
          </Text>
        ) : null}
        {error ? (
          <Text testID="external_open_error" style={styles.error}>
            Couldn’t open link: {error}
          </Text>
        ) : null}
        <Pressable testID="external_dismiss_button" style={styles.dismiss} onPress={() => dismiss()}>
          <Text style={styles.dismissText}>Dismiss</Text>
        </Pressable>
      </View>
    </View>
  );
}

const styles = StyleSheet.create({
  wrap: { position: 'absolute', top: 0, left: 0, right: 0, bottom: 0, justifyContent: 'flex-start', alignItems: 'stretch', zIndex: 40 },
  banner: { marginTop: 44, marginHorizontal: 12, backgroundColor: '#222', borderRadius: 8, padding: 14, gap: 8, elevation: 10 },
  url: { color: '#8fd0ff', fontSize: 13 },
  error: { color: '#ff8f8f', fontSize: 14, fontWeight: '600' },
  dismiss: { alignSelf: 'flex-end' },
  dismissText: { color: '#fff', fontWeight: '600' },
});
