import { Image } from 'expo-image';
import { Pressable, StyleSheet, Text, View } from 'react-native';

import type { VideoData } from '@/types/video';

type VideoItemProps = {
  video: VideoData;
  onPress: (video: VideoData) => void | Promise<void>;
};

export function VideoItem({ video, onPress }: VideoItemProps) {
  const locationParts = [video.location?.city, video.location?.country].filter(Boolean);

  return (
    <Pressable onPress={() => void onPress(video)} style={({ pressed }) => [styles.card, pressed && styles.cardPressed]}>
      <Image source={{ uri: video.thumbnailUrl }} style={styles.thumbnail} contentFit="cover" />
      <View style={styles.content}>
        <Text style={styles.title} numberOfLines={2}>
          {video.title}
        </Text>
        <Text style={styles.channelName} numberOfLines={1}>
          {video.channelName}
        </Text>
        <Text style={styles.metaText}>Published: {video.publishedAt.slice(0, 10)}</Text>
        {video.recordingDate ? <Text style={styles.metaText}>Recorded: {video.recordingDate}</Text> : null}
        {locationParts.length ? <Text style={styles.metaText}>📍 {locationParts.join(', ')}</Text> : null}
        {video.tags.length ? (
          <Text style={styles.tags} numberOfLines={2}>
            {video.tags.slice(0, 5).join(', ')}
          </Text>
        ) : null}
      </View>
    </Pressable>
  );
}

const styles = StyleSheet.create({
  card: {
    flexDirection: 'row',
    borderRadius: 18,
    backgroundColor: '#ffffff',
    padding: 12,
    shadowColor: '#101828',
    shadowOpacity: 0.08,
    shadowRadius: 12,
    shadowOffset: { width: 0, height: 8 },
    elevation: 3,
  },
  cardPressed: {
    opacity: 0.92,
  },
  thumbnail: {
    width: 120,
    height: 90,
    borderRadius: 12,
    backgroundColor: '#d0d5dd',
    marginRight: 12,
  },
  content: {
    flex: 1,
    gap: 4,
  },
  title: {
    fontSize: 15,
    fontWeight: '700',
    color: '#101828',
  },
  channelName: {
    fontSize: 13,
    fontWeight: '600',
    color: '#344054',
  },
  metaText: {
    fontSize: 12,
    color: '#475467',
  },
  tags: {
    fontSize: 12,
    color: '#667085',
    fontStyle: 'italic',
  },
});
