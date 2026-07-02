import { Pressable, StyleSheet, Text, View } from 'react-native';

import { Video } from '../../domain/types';

// A plain absolutely-positioned View, NOT RN `Modal` — keeps its testIDs in the same accessibility
// surface as the rest of the screen with zero extra work (cross-framework-setup.md §C, the RN
// reference: "the native sheet is a plain absolutely-positioned View, not a separate window").
export function DetailBottomSheet({ video, onOpenYoutube, onClose }: { video: Video; onOpenYoutube: (video: Video) => void; onClose: () => void }) {
  return (
    <View testID="detail_bottom_sheet" style={styles.sheet}>
      <Pressable onPress={onClose} style={styles.closeButton}>
        <Text style={styles.closeText}>Close</Text>
      </Pressable>
      <Text style={styles.title} numberOfLines={2}>
        {video.title}
      </Text>
      <Text testID="detail_video_url" style={styles.url}>
        {video.youtubeUrl}
      </Text>
      <Pressable testID="detail_open_youtube_button" onPress={() => onOpenYoutube(video)} style={styles.button}>
        <Text style={styles.buttonText}>Open in YouTube</Text>
      </Pressable>
    </View>
  );
}

const styles = StyleSheet.create({
  sheet: {
    position: 'absolute',
    left: 0,
    right: 0,
    bottom: 0,
    backgroundColor: '#fff',
    padding: 16,
    borderTopLeftRadius: 16,
    borderTopRightRadius: 16,
    gap: 8,
    shadowColor: '#000',
    shadowOpacity: 0.2,
    shadowRadius: 8,
    elevation: 8,
  },
  closeButton: { alignSelf: 'flex-end' },
  closeText: { color: '#888', fontSize: 13 },
  title: { fontSize: 16, fontWeight: '700' },
  url: { fontSize: 12, color: '#555' },
  button: { backgroundColor: '#1a73e8', paddingVertical: 10, borderRadius: 6, alignItems: 'center', marginTop: 8 },
  buttonText: { color: '#fff', fontWeight: '600' },
});
