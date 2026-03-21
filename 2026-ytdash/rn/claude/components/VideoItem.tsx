import React from 'react';
import {
  View,
  Text,
  Image,
  TouchableOpacity,
  StyleSheet,
  Linking,
  Alert,
} from 'react-native';
import type { VideoData } from '@/services/youtubeApi';

interface VideoItemProps {
  video: VideoData;
}

export default function VideoItem({ video }: VideoItemProps) {
  const handlePress = async () => {
    const videoId = video.id;

    try {
      // Try Android YouTube app deep link
      const androidDeepLink = `vnd.youtube:${videoId}`;
      const canOpen = await Linking.canOpenURL(androidDeepLink);
      if (canOpen) {
        await Linking.openURL(androidDeepLink);
        return;
      }

      // Try alternative Android URL
      const altUrl = `https://www.youtube.com/watch?v=${videoId}`;
      await Linking.openURL(altUrl);
    } catch {
      // Fallback to web browser
      try {
        await Linking.openURL(video.videoUrl);
      } catch {
        Alert.alert(
          'Cannot open video',
          'Please install the YouTube app or try again later.'
        );
      }
    }
  };

  const formattedDate = video.publishedAt
    ? new Date(video.publishedAt).toLocaleDateString()
    : '';

  return (
    <TouchableOpacity style={styles.container} onPress={handlePress}>
      <Image source={{ uri: video.thumbnailUrl }} style={styles.thumbnail} />
      <View style={styles.info}>
        <Text style={styles.title} numberOfLines={2}>
          {video.title}
        </Text>
        <Text style={styles.channel} numberOfLines={1}>
          {video.channelName}
        </Text>
        <Text style={styles.date}>{formattedDate}</Text>
        {video.recordingDate && (
          <Text style={styles.date}>Recorded: {video.recordingDate}</Text>
        )}
        {video.location && (video.location.city || video.location.country) && (
          <Text style={styles.location}>
            📍 {[video.location.city, video.location.country].filter(Boolean).join(', ')}
          </Text>
        )}
        {video.tags.length > 0 && (
          <Text style={styles.tags} numberOfLines={1}>
            {video.tags.slice(0, 5).join(', ')}
          </Text>
        )}
      </View>
    </TouchableOpacity>
  );
}

const styles = StyleSheet.create({
  container: {
    flexDirection: 'row',
    padding: 12,
    marginHorizontal: 12,
    marginVertical: 6,
    backgroundColor: '#fff',
    borderRadius: 8,
    elevation: 2,
    shadowColor: '#000',
    shadowOffset: { width: 0, height: 1 },
    shadowOpacity: 0.1,
    shadowRadius: 2,
  },
  thumbnail: {
    width: 120,
    height: 90,
    borderRadius: 6,
  },
  info: {
    flex: 1,
    marginLeft: 12,
    justifyContent: 'center',
  },
  title: {
    fontSize: 14,
    fontWeight: '600',
    color: '#111',
  },
  channel: {
    fontSize: 12,
    color: '#666',
    marginTop: 2,
  },
  date: {
    fontSize: 11,
    color: '#888',
    marginTop: 1,
  },
  location: {
    fontSize: 11,
    color: '#555',
    marginTop: 2,
  },
  tags: {
    fontSize: 10,
    color: '#999',
    fontStyle: 'italic',
    marginTop: 2,
  },
});
