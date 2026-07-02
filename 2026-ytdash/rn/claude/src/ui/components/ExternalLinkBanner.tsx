import { Pressable, StyleSheet, Text, View } from 'react-native';

import { useExternalLinkStore } from '../../state/externalLinkStore';

// Mounted once at the app root (App.tsx) so it can serve both the video list and the map's
// detail sheet without duplication (plan.md "Key design choices" #2).
export function ExternalLinkBanner() {
  const capturedUrl = useExternalLinkStore((s) => s.capturedUrl);
  const errorMessage = useExternalLinkStore((s) => s.errorMessage);
  const clear = useExternalLinkStore((s) => s.clear);

  if (!capturedUrl && !errorMessage) return null;

  return (
    <View style={styles.wrapper} pointerEvents="box-none">
      {capturedUrl ? (
        <View style={[styles.banner, styles.info]}>
          {/* testID directly on the Text node (not a wrapping View) so the accessibility
              "text" attribute is set on the SAME node Maestro reads — no child-to-parent
              text merging involved, which otherwise can perturb exact-string comparisons
              like AC-MAP-03's copiedText check. */}
          <Text testID="external_open_url" style={styles.text}>
            {capturedUrl}
          </Text>
        </View>
      ) : null}
      {errorMessage ? (
        <View style={[styles.banner, styles.error]}>
          <Text testID="external_open_error" style={styles.text}>
            {errorMessage}
          </Text>
        </View>
      ) : null}
      <Pressable onPress={clear} style={styles.dismiss}>
        <Text style={styles.dismissText}>Dismiss</Text>
      </Pressable>
    </View>
  );
}

const styles = StyleSheet.create({
  wrapper: { position: 'absolute', top: 0, left: 0, right: 0, paddingTop: 40, paddingHorizontal: 12, gap: 6, zIndex: 100 },
  banner: { padding: 10, borderRadius: 6 },
  info: { backgroundColor: '#1a73e8' },
  error: { backgroundColor: '#b00020' },
  text: { color: '#fff', fontSize: 13 },
  dismiss: { alignSelf: 'flex-end' },
  dismissText: { color: '#1a73e8', fontSize: 12 },
});
