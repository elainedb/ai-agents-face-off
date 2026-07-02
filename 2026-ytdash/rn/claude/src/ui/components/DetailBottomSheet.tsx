import React from 'react';
import { Pressable, StyleSheet, Text, View } from 'react-native';

import type { Video } from '../../domain/models';

type Props = {
  video: Video;
  onOpenYoutube: (video: Video) => void;
  onClose: () => void;
};

export function DetailBottomSheet({ video, onOpenYoutube, onClose }: Props) {
  return (
    <View testID="detail_bottom_sheet" style={styles.sheet}>
      <Pressable style={styles.closeArea} onPress={onClose}>
        <Text style={styles.closeText}>✕</Text>
      </Pressable>
      <Text style={styles.title} numberOfLines={2}>
        {video.title}
      </Text>
      <Text style={styles.description} numberOfLines={3}>
        {video.description}
      </Text>
      <Text testID="detail_video_url" style={styles.url}>
        {video.youtubeUrl}
      </Text>
      <Pressable testID="detail_open_youtube_button" style={styles.button} onPress={() => onOpenYoutube(video)}>
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
    backgroundColor: 'white',
    padding: 16,
    borderTopLeftRadius: 16,
    borderTopRightRadius: 16,
    shadowColor: '#000',
    shadowOpacity: 0.2,
    shadowRadius: 8,
    elevation: 8,
  },
  closeArea: {
    position: 'absolute',
    top: 8,
    right: 12,
    padding: 8,
  },
  closeText: {
    fontSize: 16,
    color: '#666',
  },
  title: {
    fontSize: 16,
    fontWeight: '700',
    marginBottom: 6,
    paddingRight: 24,
  },
  description: {
    fontSize: 13,
    color: '#666',
    marginBottom: 8,
  },
  url: {
    fontSize: 12,
    color: '#1a73e8',
    marginBottom: 12,
  },
  button: {
    backgroundColor: '#1a73e8',
    paddingVertical: 12,
    borderRadius: 6,
    alignItems: 'center',
  },
  buttonText: {
    color: 'white',
    fontWeight: '600',
  },
});
