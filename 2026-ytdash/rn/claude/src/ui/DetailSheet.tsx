import React from 'react';
import { Pressable, StyleSheet, Text, View } from 'react-native';

import { useStore } from '../state/store';

// Bottom sheet for a tapped marker (AC-MAP-02/03). A plain absolutely-positioned View in the main
// tree (NOT a separate window), so its testIDs are always reachable (constitution §5a).
export function DetailSheet() {
  const video = useStore((s) => s.selectedVideo);
  const closeSheet = useStore((s) => s.closeSheet);
  const openExternal = useStore((s) => s.openExternal);

  if (!video) return null;

  return (
    <View style={styles.scrim} pointerEvents="box-none">
      <View testID="detail_bottom_sheet" style={styles.sheet}>
        <Text style={styles.title} numberOfLines={2}>
          {video.title}
        </Text>
        <Text style={styles.desc} numberOfLines={3}>
          {video.description}
        </Text>
        {/* Exact watch URL — the harness copies this and compares it to the opened URL (AC-MAP-03). */}
        <Text testID="detail_video_url" style={styles.url}>
          {video.youtubeUrl}
        </Text>

        <View style={styles.actions}>
          <Pressable
            testID="detail_open_youtube_button"
            style={styles.openButton}
            onPress={() => openExternal(video.youtubeUrl)}
          >
            <Text style={styles.openText}>Open in YouTube</Text>
          </Pressable>
          <Pressable testID="detail_close_button" style={styles.closeButton} onPress={() => closeSheet()}>
            <Text style={styles.closeText}>Close</Text>
          </Pressable>
        </View>
      </View>
    </View>
  );
}

const styles = StyleSheet.create({
  scrim: { position: 'absolute', top: 0, left: 0, right: 0, bottom: 0, justifyContent: 'flex-end', zIndex: 30 },
  sheet: {
    backgroundColor: '#fff',
    padding: 20,
    borderTopLeftRadius: 16,
    borderTopRightRadius: 16,
    borderTopWidth: StyleSheet.hairlineWidth,
    borderColor: '#ccc',
    elevation: 12,
    gap: 8,
  },
  title: { fontSize: 18, fontWeight: '700', color: '#111' },
  desc: { fontSize: 14, color: '#555' },
  url: { fontSize: 13, color: '#1a56c4', marginTop: 4 },
  actions: { flexDirection: 'row', gap: 12, marginTop: 12 },
  openButton: { flex: 1, backgroundColor: '#c00', paddingVertical: 14, borderRadius: 8, alignItems: 'center' },
  openText: { color: '#fff', fontWeight: '700', fontSize: 16 },
  closeButton: { paddingVertical: 14, paddingHorizontal: 20, borderRadius: 8, backgroundColor: '#eee', alignItems: 'center' },
  closeText: { color: '#222', fontWeight: '600', fontSize: 16 },
});
