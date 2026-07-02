import React from 'react';
import { Pressable, ScrollView, StyleSheet, Text } from 'react-native';
import { Video } from '../domain/types';

type Props = {
  videos: Video[];
  onSelect: (video: Video) => void;
};

/**
 * Rendered map pins (Leaflet inside a WebView) live in the WebView's DOM and are not reachable by
 * a black-box a11y-driven automation tool. This native chip row is the accessible affordance the
 * constitution requires (§5) — one Pressable per located video, all sharing `map_marker`.
 */
export function MapMarkers({ videos, onSelect }: Props) {
  const located = videos.filter((v) => v.location);
  return (
    <ScrollView horizontal style={styles.row} contentContainerStyle={styles.rowContent}>
      {located.map((video) => (
        <Pressable key={video.id} testID="map_marker" style={styles.chip} onPress={() => onSelect(video)}>
          <Text numberOfLines={1} style={styles.chipText}>
            {video.title}
          </Text>
        </Pressable>
      ))}
    </ScrollView>
  );
}

const styles = StyleSheet.create({
  row: {
    maxHeight: 64,
    backgroundColor: 'white',
  },
  rowContent: {
    paddingHorizontal: 8,
    paddingVertical: 8,
    gap: 8,
  },
  chip: {
    backgroundColor: '#dbeafe',
    borderRadius: 16,
    paddingHorizontal: 14,
    paddingVertical: 8,
    marginRight: 8,
    maxWidth: 160,
  },
  chipText: {
    fontSize: 13,
    color: '#1e3a8a',
  },
});
