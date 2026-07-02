import React from 'react';
import { Pressable, ScrollView, StyleSheet, Text } from 'react-native';

import type { Video } from '../../domain/models';

type Props = {
  videos: Video[];
  onSelect: (video: Video) => void;
};

export function MapMarkers({ videos, onSelect }: Props) {
  return (
    <ScrollView horizontal style={styles.row} contentContainerStyle={styles.rowContent} showsHorizontalScrollIndicator={false}>
      {videos.map((v) => (
        <Pressable key={v.id} testID="map_marker" style={styles.chip} onPress={() => onSelect(v)}>
          <Text style={styles.chipText} numberOfLines={1}>
            {v.title}
          </Text>
        </Pressable>
      ))}
    </ScrollView>
  );
}

const styles = StyleSheet.create({
  row: {
    maxHeight: 64,
    backgroundColor: '#fff',
    borderTopWidth: StyleSheet.hairlineWidth,
    borderTopColor: '#ddd',
  },
  rowContent: {
    padding: 8,
    gap: 8,
  },
  chip: {
    backgroundColor: '#f0f0f0',
    paddingVertical: 8,
    paddingHorizontal: 12,
    borderRadius: 16,
    maxWidth: 160,
  },
  chipText: {
    fontSize: 12,
  },
});
