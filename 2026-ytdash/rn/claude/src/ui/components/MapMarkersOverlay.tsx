import { Pressable, ScrollView, StyleSheet, Text } from 'react-native';

import { Video } from '../../domain/types';

// The Maestro-reachable affordance (constitution §5): WebView/Leaflet DOM pins are NOT reachable
// by a black-box automation tool, so every located video also gets a native chip here. All chips
// share the `map_marker` testID — Maestro selects among them by `index`.
export function MapMarkersOverlay({ videos, onSelect }: { videos: Video[]; onSelect: (video: Video) => void }) {
  return (
    <ScrollView horizontal contentContainerStyle={styles.row} style={styles.container} showsHorizontalScrollIndicator={false}>
      {videos.map((video) => (
        <Pressable key={video.id} testID="map_marker" onPress={() => onSelect(video)} style={styles.chip}>
          <Text style={styles.chipText} numberOfLines={1}>
            {video.title}
          </Text>
        </Pressable>
      ))}
    </ScrollView>
  );
}

const styles = StyleSheet.create({
  container: { maxHeight: 64, backgroundColor: '#fff' },
  row: { paddingHorizontal: 12, paddingVertical: 10, gap: 8 },
  chip: { backgroundColor: '#f2f2f2', paddingVertical: 8, paddingHorizontal: 14, borderRadius: 20, maxWidth: 160 },
  chipText: { fontSize: 12, fontWeight: '600', color: '#1a73e8' },
});
