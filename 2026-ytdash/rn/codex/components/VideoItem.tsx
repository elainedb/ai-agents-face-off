import { Alert, Image, Linking, Pressable, StyleSheet, Text, View } from 'react-native';

import type { VideoData } from '@/services/youtubeApi';

type Props = {
  video: VideoData;
};

export default function VideoItem({ video }: Props) {
  const openVideo = async () => {
    const urls = [
      `vnd.youtube:${video.id}`,
      `vnd.youtube://watch?v=${video.id}`,
      video.videoUrl,
    ];

    for (const url of urls) {
      const canOpen = await Linking.canOpenURL(url);
      if (canOpen) {
        await Linking.openURL(url);
        return;
      }
    }

    Alert.alert('Unable to open video', 'Install the YouTube app or try opening it again.');
  };

  return (
    <Pressable onPress={() => void openVideo()} style={styles.card}>
      <Image source={{ uri: video.thumbnailUrl }} style={styles.thumbnail} />
      <View style={styles.content}>
        <Text numberOfLines={2} style={styles.title}>{video.title}</Text>
        <Text numberOfLines={1} style={styles.channel}>{video.channelName}</Text>
        <Text style={styles.meta}>Published: {video.publishedAt.slice(0, 10)}</Text>
        {video.recordingDate ? <Text style={styles.meta}>Recorded: {video.recordingDate}</Text> : null}
        {video.location?.country ? (
          <Text style={styles.meta}>
            Pin: {[video.location.city, video.location.country].filter(Boolean).join(', ')}
          </Text>
        ) : null}
        {video.tags.length > 0 ? (
          <Text numberOfLines={2} style={styles.tags}>{video.tags.slice(0, 5).join(', ')}</Text>
        ) : null}
      </View>
    </Pressable>
  );
}

const styles = StyleSheet.create({
  card: {
    backgroundColor: '#ffffff',
    borderRadius: 18,
    elevation: 2,
    flexDirection: 'row',
    gap: 12,
    marginBottom: 12,
    padding: 12,
    shadowColor: '#000000',
    shadowOffset: { width: 0, height: 2 },
    shadowOpacity: 0.08,
    shadowRadius: 8,
  },
  thumbnail: {
    borderRadius: 12,
    height: 90,
    width: 120,
  },
  content: {
    flex: 1,
  },
  title: {
    color: '#14213d',
    fontSize: 15,
    fontWeight: '700',
    marginBottom: 4,
  },
  channel: {
    color: '#52627a',
    fontSize: 13,
    fontWeight: '600',
    marginBottom: 6,
  },
  meta: {
    color: '#52627a',
    fontSize: 12,
    marginBottom: 2,
  },
  tags: {
    color: '#6c7a91',
    fontSize: 12,
    fontStyle: 'italic',
    marginTop: 4,
  },
});
