import { Image } from 'expo-image';
import * as Linking from 'expo-linking';
import { Alert, Platform, Pressable, StyleSheet, Text, View } from 'react-native';

import type { Video } from '@/src/features/videos/domain/entities/video';
import {
  hasCoordinates,
  hasRecordingDate,
  locationText,
} from '@/src/features/videos/domain/utils/video-utils';

const formatDate = (date: Date) => date.toISOString().slice(0, 10);

const openVideo = async (videoId: string) => {
  const deepLink = Platform.OS === 'android' ? `vnd.youtube:${videoId}` : `youtube://${videoId}`;
  const webUrl = `https://www.youtube.com/watch?v=${videoId}`;

  try {
    const canOpen = await Linking.canOpenURL(deepLink);
    await Linking.openURL(canOpen ? deepLink : webUrl);
  } catch {
    Alert.alert('Unable to open video', 'Please try again from a browser.');
  }
};

interface VideoItemProps {
  video: Video;
}

export function VideoItem({ video }: VideoItemProps) {
  const visibleTags = video.tags.slice(0, 5);
  const extraTagCount = Math.max(0, video.tags.length - visibleTags.length);

  return (
    <Pressable style={styles.card} onPress={() => void openVideo(video.id)}>
      <Image
        source={{ uri: video.thumbnailUrl }}
        style={styles.thumbnail}
        contentFit="cover"
        placeholder={{ blurhash: 'LEHV6nWB2yk8pyo0adR*.7kCMdnj' }}
      />
      <View style={styles.content}>
        <Text style={styles.title} numberOfLines={2}>
          {video.title}
        </Text>
        <Text style={styles.channel} numberOfLines={1}>
          {video.channelName}
        </Text>
        <Text style={styles.meta}>Published: {formatDate(video.publishedAt)}</Text>
        {hasRecordingDate(video) ? (
          <Text style={styles.meta}>Recorded: {formatDate(video.recordingDate as Date)}</Text>
        ) : null}
        <Text style={styles.meta}>Location: {locationText(video)}</Text>
        {hasCoordinates(video) ? (
          <Text style={styles.meta}>
            GPS: {video.latitude?.toFixed(4)}, {video.longitude?.toFixed(4)}
          </Text>
        ) : null}
        {visibleTags.length > 0 ? (
          <View style={styles.tagsRow}>
            {visibleTags.map((tag) => (
              <View key={tag} style={styles.tag}>
                <Text style={styles.tagText}>#{tag}</Text>
              </View>
            ))}
            {extraTagCount > 0 ? <Text style={styles.moreTags}>+{extraTagCount} more</Text> : null}
          </View>
        ) : null}
      </View>
    </Pressable>
  );
}

const styles = StyleSheet.create({
  card: {
    backgroundColor: '#ffffff',
    borderRadius: 18,
    marginBottom: 16,
    overflow: 'hidden',
    borderWidth: 1,
    borderColor: '#dbe4ff',
  },
  thumbnail: {
    width: '100%',
    height: 208,
    backgroundColor: '#d7def2',
  },
  content: {
    padding: 16,
    gap: 6,
  },
  title: {
    fontSize: 18,
    lineHeight: 24,
    fontWeight: '700',
    color: '#13203a',
  },
  channel: {
    fontSize: 14,
    fontWeight: '600',
    color: '#4b5b7c',
  },
  meta: {
    fontSize: 13,
    color: '#5c6c8f',
  },
  tagsRow: {
    flexDirection: 'row',
    flexWrap: 'wrap',
    gap: 8,
    marginTop: 4,
  },
  tag: {
    paddingHorizontal: 10,
    paddingVertical: 6,
    borderRadius: 999,
    backgroundColor: '#edf3ff',
  },
  tagText: {
    color: '#2450a6',
    fontSize: 12,
    fontWeight: '600',
  },
  moreTags: {
    fontSize: 12,
    color: '#7382a5',
    alignSelf: 'center',
  },
});
