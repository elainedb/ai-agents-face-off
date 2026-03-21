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
      if (Platform.OS === 'android') {
        const androidUrl = `vnd.youtube:${video.id}`;
        const canOpen = await Linking.canOpenURL(androidUrl);
        if (canOpen) {
          await Linking.openURL(androidUrl);
          return;
        }
        // Try alternative Android URL
        const altUrl = `https://www.youtube.com/watch?v=${video.id}`;
        await Linking.openURL(altUrl);
      } else {
        const iosUrl = `youtube://${video.id}`;
        const canOpen = await Linking.canOpenURL(iosUrl);
        if (canOpen) {
          await Linking.openURL(iosUrl);
          return;
        }
        await Linking.openURL(video.videoUrl);
      }
    } catch {
      Alert.alert(
        'Error',
        'Could not open video. Please make sure the YouTube app is installed.',
      );
    }
  };

  const formattedDate = new Date(video.publishedAt).toLocaleDateString();

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
    borderBottomWidth: 1,
    borderBottomColor: '#eee',
    backgroundColor: '#fff',
  },
  thumbnail: {
    width: 120,
    height: 90,
    borderRadius: 8,
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
    marginBottom: 4,
  },
  channel: {
    fontSize: 12,
    color: '#666',
    marginBottom: 2,
  },
  date: {
    fontSize: 11,
    color: '#999',
  },
  location: {
    fontSize: 11,
    color: '#666',
    marginTop: 2,
  },
  tags: {
    fontSize: 10,
    color: '#888',
    fontStyle: 'italic',
    marginTop: 2,
  },
});
