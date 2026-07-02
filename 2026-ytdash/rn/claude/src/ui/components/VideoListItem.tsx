import React from 'react';
import { Image, Pressable, StyleSheet, Text, View } from 'react-native';

import type { Video } from '../../domain/models';

type Props = {
  video: Video;
  onPress: (video: Video) => void;
};

export function VideoListItem({ video, onPress }: Props) {
  return (
    <Pressable testID="video_list_item" style={styles.row} onPress={() => onPress(video)}>
      <Image source={{ uri: video.thumbnailUrl }} style={styles.thumb} />
      <View style={styles.info}>
        <Text style={styles.title} numberOfLines={2}>
          {video.title}
        </Text>
        <Text style={styles.meta} numberOfLines={2}>
          {video.category} · {video.publishedAt.slice(0, 10)}
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
    borderBottomWidth: StyleSheet.hairlineWidth,
    borderBottomColor: '#ddd',
  },
  thumb: {
    width: 100,
    height: 60,
    borderRadius: 4,
    backgroundColor: '#eee',
  },
  info: {
    flex: 1,
    marginLeft: 12,
  },
  title: {
    fontSize: 15,
    fontWeight: '600',
  },
  meta: {
    fontSize: 12,
    color: '#666',
    marginTop: 2,
  },
  description: {
    fontSize: 12,
    color: '#888',
    marginTop: 2,
  },
});
