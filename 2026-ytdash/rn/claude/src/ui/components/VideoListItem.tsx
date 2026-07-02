import { Image, Pressable, StyleSheet, Text, View } from 'react-native';

import { Video } from '../../domain/types';

export function VideoListItem({ video, onPress }: { video: Video; onPress: (video: Video) => void }) {
  return (
    <Pressable testID="video_list_item" onPress={() => onPress(video)} style={styles.row}>
      <Image source={{ uri: video.thumbnailUrl }} style={styles.thumbnail} />
      <View style={styles.textColumn}>
        <Text style={styles.title} numberOfLines={2}>
          {video.title}
        </Text>
        <Text style={styles.meta} numberOfLines={1}>
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
  row: { flexDirection: 'row', padding: 12, gap: 12, borderBottomWidth: StyleSheet.hairlineWidth, borderBottomColor: '#ddd' },
  thumbnail: { width: 100, height: 64, borderRadius: 6, backgroundColor: '#eee' },
  textColumn: { flex: 1, gap: 4 },
  title: { fontSize: 15, fontWeight: '600' },
  meta: { fontSize: 12, color: '#888' },
  description: { fontSize: 13, color: '#555' },
});
