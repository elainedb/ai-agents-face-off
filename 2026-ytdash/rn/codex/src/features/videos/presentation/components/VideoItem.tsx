import { Image } from 'expo-image';
import { Linking, Pressable, StyleSheet, Text, View } from 'react-native';

import { Video } from '@/src/features/videos/domain/entities/video';
import { hasCoordinates, hasRecordingDate, hasLocation } from '@/src/features/videos/domain/utils/video-utils';

const formatDate = (date: Date | null): string | null => {
  if (!date) {
    return null;
  }

  return date.toISOString().slice(0, 10);
};

const openVideo = async (videoId: string) => {
  const appUrl = `vnd.youtube:${videoId}`;
  const browserUrl = `https://www.youtube.com/watch?v=${videoId}`;
  const canOpenApp = await Linking.canOpenURL(appUrl);

  await Linking.openURL(canOpenApp ? appUrl : browserUrl);
};

interface VideoItemProps {
  video: Video;
}

export function VideoItem({ video }: VideoItemProps) {
  return (
    <Pressable onPress={() => openVideo(video.id)} style={styles.card}>
      <Image source={video.thumbnailUrl} style={styles.thumbnail} contentFit="cover" />
      <View style={styles.content}>
        <Text numberOfLines={2} style={styles.title}>
          {video.title}
        </Text>
        <Text numberOfLines={1} style={styles.channelName}>
          {video.channelName}
        </Text>
        <Text style={styles.meta}>Published: {formatDate(video.publishedAt)}</Text>
        {hasRecordingDate(video) ? (
          <Text style={styles.meta}>Recorded: {formatDate(video.recordingDate)}</Text>
        ) : null}
        {hasLocation(video) ? (
          <Text style={styles.meta}>
            Location: {[video.city, video.country].filter(Boolean).join(', ')}
          </Text>
        ) : null}
        {hasCoordinates(video) ? (
          <Text style={styles.meta}>
            GPS: {video.latitude?.toFixed(4)}, {video.longitude?.toFixed(4)}
          </Text>
        ) : null}
        {video.tags.length > 0 ? (
          <View style={styles.tagsRow}>
            {video.tags.slice(0, 5).map((tag) => (
              <View key={tag} style={styles.tag}>
                <Text style={styles.tagText}>{tag}</Text>
              </View>
            ))}
            {video.tags.length > 5 ? (
              <Text style={styles.moreText}>+{video.tags.length - 5} more</Text>
            ) : null}
          </View>
        ) : null}
      </View>
    </Pressable>
  );
}

export { openVideo };

const styles = StyleSheet.create({
  card: {
    backgroundColor: '#fff',
    borderRadius: 18,
    marginBottom: 16,
    overflow: 'hidden',
    borderWidth: 1,
    borderColor: '#dde5ef',
  },
  thumbnail: {
    width: '100%',
    height: 210,
    backgroundColor: '#cfd8e3',
  },
  content: {
    padding: 16,
    gap: 6,
  },
  title: {
    fontSize: 18,
    fontWeight: '700',
    color: '#112031',
  },
  channelName: {
    fontSize: 14,
    fontWeight: '600',
    color: '#3b556d',
  },
  meta: {
    fontSize: 13,
    color: '#495b70',
  },
  tagsRow: {
    flexDirection: 'row',
    flexWrap: 'wrap',
    gap: 8,
    marginTop: 6,
    alignItems: 'center',
  },
  tag: {
    backgroundColor: '#e8f1fb',
    borderRadius: 999,
    paddingHorizontal: 10,
    paddingVertical: 4,
  },
  tagText: {
    color: '#1d4f8c',
    fontSize: 12,
    fontWeight: '600',
  },
  moreText: {
    color: '#3b556d',
    fontSize: 12,
    fontWeight: '600',
  },
});
