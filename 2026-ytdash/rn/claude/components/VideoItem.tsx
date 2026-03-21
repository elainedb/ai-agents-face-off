import React from 'react';
import {
  View,
  Text,
  Image,
  TouchableOpacity,
  StyleSheet,
  Linking,
  Alert,
  Platform,
} from 'react-native';
import type { VideoData } from '@/services/youtubeApi';

interface VideoItemProps {
  video: VideoData;
}

export default function VideoItem({ video }: VideoItemProps) {
  const handlePress = async () => {
    try {
      // Android-specific YouTube deep link
      const androidUrl = `vnd.youtube:${video.id}`;
      const altAndroidUrl = `youtube://watch?v=${video.id}`;
      const webUrl = video.videoUrl;

      if (Platform.OS === 'android') {
        const canOpen = await Linking.canOpenURL(androidUrl);
        if (canOpen) {
          await Linking.openURL(androidUrl);
          return;
        }

        const canOpenAlt = await Linking.canOpenURL(altAndroidUrl);
        if (canOpenAlt) {
          await Linking.openURL(altAndroidUrl);
          return;
        }
      }

      await Linking.openURL(webUrl);
    } catch {
      Alert.alert(
        'Error',
        'Could not open video. Please install the YouTube app or try again.',
      );
    }
  };

  const formatDate = (dateStr: string) => {
    return new Date(dateStr).toISOString().split('T')[0];
  };

  return (
    <TouchableOpacity style={styles.container} onPress={handlePress}>
      <Image
        source={{ uri: video.thumbnailUrl }}
        style={styles.thumbnail}
      />
      <View style={styles.info}>
        <Text style={styles.title} numberOfLines={2}>
          {video.title}
        </Text>
        <Text style={styles.channel} numberOfLines={1}>
          {video.channelName}
        </Text>
        <Text style={styles.date}>
          Published: {formatDate(video.publishedAt)}
        </Text>
        {video.recordingDate && (
          <Text style={styles.date}>Recorded: {video.recordingDate}</Text>
        )}
        {video.location && (video.location.city || video.location.country) && (
          <Text style={styles.location}>
            📍{' '}
            {[video.location.city, video.location.country]
              .filter(Boolean)
              .join(', ')}
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
    borderBottomWidth: 1,
    borderBottomColor: '#eee',
    backgroundColor: '#fff',
  },
  thumbnail: {
    width: 120,
    height: 90,
    borderRadius: 8,
    backgroundColor: '#ddd',
  },
  info: {
    flex: 1,
    marginLeft: 12,
    justifyContent: 'center',
  },
  title: {
    fontSize: 14,
    fontWeight: '600',
    color: '#333',
    marginBottom: 2,
  },
  channel: {
    fontSize: 12,
    color: '#666',
    marginBottom: 2,
  },
  date: {
    fontSize: 11,
    color: '#888',
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
