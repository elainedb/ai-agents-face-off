import React from 'react';
import { Image, Pressable, StyleSheet, Text, View } from 'react-native';
import { Video } from '../domain/types';

type Props = {
  video: Video;
  onPress: (video: Video) => void;
};

export function VideoListItem({ video, onPress }: Props) {
  return (
    <Pressable testID="video_list_item" style={styles.row} onPress={() => onPress(video)}>
      {video.thumbnailUrl ? (
        <Image source={{ uri: video.thumbnailUrl }} style={styles.thumb} />
      ) : (
        <View style={[styles.thumb, styles.thumbPlaceholder]} />
      )}
      <View style={styles.textColumn}>
        <Text style={styles.title} numberOfLines={2}>
          {video.title}
        </Text>
        <Text style={styles.meta} numberOfLines={2}>
          {video.category} · {new Date(video.publishedAt).toLocaleDateString()}
        </Text>
        <Text style={styles.description} numberOfLines={2}>
          {video.description}
        </Text>
      </View>
    </Pressable>
  );
}

const styles = StyleSheet.create({
  row: {
    flexDirection: 'row',
    padding: 12,
    gap: 12,
    borderBottomWidth: StyleSheet.hairlineWidth,
    borderBottomColor: '#e5e7eb',
  },
  thumb: {
    width: 96,
    height: 64,
    borderRadius: 6,
    backgroundColor: '#e5e7eb',
  },
  thumbPlaceholder: {},
  textColumn: {
    flex: 1,
    gap: 4,
  },
  title: {
    fontSize: 15,
    fontWeight: '600',
  },
  meta: {
    fontSize: 12,
    color: '#6b7280',
  },
  description: {
    fontSize: 12,
    color: '#374151',
  },
});
