import React from 'react';
import { StyleSheet, Text, View } from 'react-native';

import { useExternalLinkStore } from '../../state/externalLinkStore';

export function ExternalLinkBanner() {
  const capturedUrl = useExternalLinkStore((s) => s.capturedUrl);
  const errored = useExternalLinkStore((s) => s.errored);

  if (!capturedUrl && !errored) return null;

  return (
    <View style={styles.container} pointerEvents="box-none">
      {capturedUrl ? (
        <View style={styles.banner}>
          <Text testID="external_open_url" style={styles.text}>
            {capturedUrl}
          </Text>
        </View>
      ) : null}
      {errored ? (
        <View style={[styles.banner, styles.errorBanner]}>
          <Text testID="external_open_error" style={styles.text}>
            Could not open link
          </Text>
        </View>
      ) : null}
    </View>
  );
}

const styles = StyleSheet.create({
  container: {
    position: 'absolute',
    bottom: 0,
    left: 0,
    right: 0,
    zIndex: 1000,
  },
  banner: {
    backgroundColor: '#222',
    padding: 10,
  },
  errorBanner: {
    backgroundColor: '#a00',
  },
  text: {
    color: 'white',
    fontSize: 12,
  },
});
