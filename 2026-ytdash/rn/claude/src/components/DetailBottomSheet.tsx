import React from 'react';
import { Pressable, StyleSheet, Text, View } from 'react-native';
import { Video } from '../domain/types';

type Props = {
  video: Video;
  onOpenYoutube: (video: Video) => void;
  onClose: () => void;
};

/**
 * A plain absolutely-positioned View, NOT a RN Modal — Modals render in a separate native window
 * whose testIDs are unreachable to the automation layer (constitution §5a's popup trap).
 */
export function DetailBottomSheet({ video, onOpenYoutube, onClose }: Props) {
  return (
    <View testID="detail_bottom_sheet" style={styles.sheet}>
      <Pressable style={styles.closeButton} onPress={onClose}>
        <Text style={styles.closeText}>✕</Text>
      </Pressable>
      <Text style={styles.title}>{video.title}</Text>
      <Text style={styles.description} numberOfLines={3}>
        {video.description}
      </Text>
      <Text testID="detail_video_url" style={styles.url}>
        {video.youtubeUrl}
      </Text>
      <Pressable
        testID="detail_open_youtube_button"
        style={styles.openButton}
        onPress={() => onOpenYoutube(video)}
      >
        <Text style={styles.openButtonText}>Open in YouTube</Text>
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
    backgroundColor: 'white',
    borderTopLeftRadius: 16,
    borderTopRightRadius: 16,
    padding: 20,
    gap: 8,
    shadowColor: '#000',
    shadowOffset: { width: 0, height: -2 },
    shadowOpacity: 0.15,
    shadowRadius: 8,
    elevation: 8,
  },
  closeButton: {
    position: 'absolute',
    right: 16,
    top: 12,
    padding: 4,
  },
  closeText: {
    fontSize: 18,
    color: '#6b7280',
  },
  title: {
    fontSize: 17,
    fontWeight: '700',
    paddingRight: 24,
  },
  description: {
    fontSize: 13,
    color: '#374151',
  },
  url: {
    fontSize: 12,
    color: '#2563eb',
  },
  openButton: {
    marginTop: 8,
    backgroundColor: '#dc2626',
    paddingVertical: 12,
    borderRadius: 8,
    alignItems: 'center',
  },
  openButtonText: {
    color: 'white',
    fontWeight: '600',
  },
});
