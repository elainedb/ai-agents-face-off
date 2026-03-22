import { Alert, Image, Linking, Platform, StyleSheet, Text, TouchableOpacity, View } from 'react-native';

import type { VideoData } from '@/services/youtubeApi';

async function openVideo(video: VideoData) {
  const urls =
    Platform.OS === 'android'
      ? [
          `vnd.youtube:${video.id}`,
          `vnd.youtube://watch/${video.id}`,
          `https://m.youtube.com/watch?v=${video.id}`,
          video.videoUrl,
        ]
      : [`youtube://watch?v=${video.id}`, video.videoUrl];

  for (const url of urls) {
    const supported = await Linking.canOpenURL(url).catch(() => url.startsWith('https://'));
    if (supported) {
      await Linking.openURL(url);
      return;
    }
  }

  Alert.alert('Unable to open video', 'Install the YouTube app or open the video in a browser.');
}

export function VideoItem({ video }: { video: VideoData }) {
  return (
    <TouchableOpacity onPress={() => void openVideo(video)} style={styles.card}>
      <Image source={{ uri: video.thumbnailUrl }} style={styles.thumbnail} />
      <View style={styles.content}>
        <Text numberOfLines={2} style={styles.title}>
          {video.title}
        </Text>
        <Text numberOfLines={1} style={styles.channel}>
          {video.channelName}
        </Text>
        <Text style={styles.meta}>Published: {video.publishedAt.slice(0, 10)}</Text>
        {video.recordingDate ? <Text style={styles.meta}>Recorded: {video.recordingDate}</Text> : null}
        {video.location?.country ? (
          <Text style={styles.meta}>
            📍 {video.location.city ? `${video.location.city}, ` : ''}
            {video.location.country}
          </Text>
        ) : null}
        {video.tags.length > 0 ? (
          <Text numberOfLines={2} style={styles.tags}>
            {video.tags.slice(0, 5).join(', ')}
          </Text>
        ) : null}
      </View>
    </TouchableOpacity>
  );
}

const styles = StyleSheet.create({
  card: {
    backgroundColor: '#ffffff',
    borderRadius: 18,
    elevation: 2,
    flexDirection: 'row',
    marginBottom: 14,
    padding: 12,
    shadowColor: '#000000',
    shadowOffset: { width: 0, height: 6 },
    shadowOpacity: 0.06,
    shadowRadius: 10,
  },
  thumbnail: {
    backgroundColor: '#e5e7eb',
    borderRadius: 12,
    height: 90,
    width: 120,
  },
  content: {
    flex: 1,
    marginLeft: 12,
  },
  title: {
    color: '#111827',
    fontSize: 15,
    fontWeight: '700',
  },
  channel: {
    color: '#2563eb',
    marginTop: 6,
  },
  meta: {
    color: '#4b5563',
    fontSize: 13,
    marginTop: 4,
  },
  tags: {
    color: '#6b7280',
    fontSize: 13,
    fontStyle: 'italic',
    marginTop: 6,
  },
});
