import { Image } from 'expo-image';
import { Pressable, StyleSheet, Text, View } from 'react-native';

import type { Video } from '@/src/features/videos/domain/entities/video';

interface VideoItemProps {
  video: Video;
  onPress: (video: Video) => void;
}

const formatDate = (date: Date | null): string | null => {
  if (!date) {
    return null;
  }

  return date.toISOString().slice(0, 10);
};

export function VideoItem({ video, onPress }: VideoItemProps) {
  const visibleTags = video.tags.slice(0, 5);
  const extraTags = Math.max(0, video.tags.length - visibleTags.length);

  return (
    <Pressable style={styles.card} onPress={() => onPress(video)}>
      <Image
        source={{ uri: video.thumbnailUrl }}
        style={styles.thumbnail}
        contentFit="cover"
        transition={200}
      />
      <View style={styles.content}>
        <Text numberOfLines={2} style={styles.title}>
          {video.title}
        </Text>
        <Text numberOfLines={1} style={styles.channel}>
          {video.channelName}
        </Text>
        <Text style={styles.meta}>Published: {formatDate(video.publishedAt)}</Text>
        {video.recordingDate ? <Text style={styles.meta}>Recorded: {formatDate(video.recordingDate)}</Text> : null}
        {video.city || video.country ? (
          <Text style={styles.meta}>
            Location: {[video.city, video.country].filter(Boolean).join(', ')}
          </Text>
        ) : null}
        {typeof video.latitude === 'number' && typeof video.longitude === 'number' ? (
          <Text style={styles.meta}>
            GPS: {video.latitude.toFixed(4)}, {video.longitude.toFixed(4)}
          </Text>
        ) : null}
        {visibleTags.length > 0 ? (
          <View style={styles.tags}>
            {visibleTags.map((tag) => (
              <View key={tag} style={styles.tag}>
                <Text style={styles.tagText}>#{tag}</Text>
              </View>
            ))}
            {extraTags > 0 ? <Text style={styles.extraTags}>+{extraTags} more</Text> : null}
          </View>
        ) : null}
      </View>
    </Pressable>
  );
}

const styles = StyleSheet.create({
  card: {
    overflow: 'hidden',
    borderRadius: 20,
    backgroundColor: '#FFFFFF',
    marginBottom: 16,
    borderWidth: 1,
    borderColor: '#D9E2F2',
  },
  thumbnail: {
    width: '100%',
    height: 200,
    backgroundColor: '#D9E2F2',
  },
  content: {
    padding: 16,
    gap: 6,
  },
  title: {
    fontSize: 18,
    fontWeight: '700',
    color: '#16213E',
  },
  channel: {
    fontSize: 14,
    fontWeight: '600',
    color: '#4285F4',
  },
  meta: {
    fontSize: 13,
    color: '#4F5D75',
  },
  tags: {
    flexDirection: 'row',
    flexWrap: 'wrap',
    gap: 8,
    marginTop: 4,
  },
  tag: {
    borderRadius: 999,
    paddingHorizontal: 10,
    paddingVertical: 5,
    backgroundColor: '#EEF3FF',
  },
  tagText: {
    fontSize: 12,
    color: '#3659B3',
  },
  extraTags: {
    alignSelf: 'center',
    color: '#4F5D75',
    fontSize: 12,
  },
});
