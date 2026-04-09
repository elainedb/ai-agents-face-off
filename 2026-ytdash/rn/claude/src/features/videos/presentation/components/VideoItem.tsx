import React from 'react';
import {
  View,
  Text,
  StyleSheet,
  TouchableOpacity,
  Platform,
  Linking,
  Alert,
} from 'react-native';
import { Image } from 'expo-image';
import { Video, hasLocation, hasCoordinates, locationText } from '../../domain/entities/video';

interface VideoItemProps {
  video: Video;
}

const openVideo = async (videoId: string) => {
  const isIOS = Platform.OS === 'ios';
  const appUrl = isIOS ? `youtube://watch?v=${videoId}` : `vnd.youtube:${videoId}`;
  const altAppUrl = `youtube://watch?v=${videoId}`;
  const webUrl = `https://www.youtube.com/watch?v=${videoId}`;

  try {
    await Linking.openURL(appUrl);
  } catch {
    if (!isIOS) {
      try {
        await Linking.openURL(altAppUrl);
      } catch {
        try {
          await Linking.openURL(webUrl);
        } catch {
          Alert.alert('Error', 'Cannot open video.');
        }
      }
    } else {
      try {
        await Linking.openURL(webUrl);
      } catch {
        Alert.alert('Error', 'Cannot open video.');
      }
    }
  }
};

function formatDate(date: Date): string {
  return date.toISOString().split('T')[0];
}

export function VideoItem({ video }: VideoItemProps) {
  const maxTags = 5;
  const visibleTags = video.tags.slice(0, maxTags);
  const remainingCount = video.tags.length - maxTags;

  return (
    <TouchableOpacity style={styles.card} onPress={() => openVideo(video.id)} activeOpacity={0.7}>
      <Image
        source={{ uri: video.thumbnailUrl }}
        style={styles.thumbnail}
        contentFit="cover"
        placeholder={require('../../../../../assets/images/icon.png')}
      />
      <View style={styles.info}>
        <Text style={styles.title} numberOfLines={2}>
          {video.title}
        </Text>
        <Text style={styles.channel} numberOfLines={1}>
          {video.channelName}
        </Text>
        <Text style={styles.date}>Published: {formatDate(video.publishedAt)}</Text>
        {video.recordingDate && (
          <Text style={styles.date}>Recorded: {formatDate(video.recordingDate)}</Text>
        )}
        {hasLocation(video) && <Text style={styles.location}>{locationText(video)}</Text>}
        {hasCoordinates(video) && (
          <Text style={styles.coords}>
            GPS: {video.latitude!.toFixed(4)}, {video.longitude!.toFixed(4)}
          </Text>
        )}
        {visibleTags.length > 0 && (
          <View style={styles.tagsRow}>
            {visibleTags.map((tag, idx) => (
              <View key={idx} style={styles.tag}>
                <Text style={styles.tagText}>{tag}</Text>
              </View>
            ))}
            {remainingCount > 0 && (
              <Text style={styles.moreTag}>+{remainingCount} more</Text>
            )}
          </View>
        )}
      </View>
    </TouchableOpacity>
  );
}

const styles = StyleSheet.create({
  card: {
    backgroundColor: '#fff',
    borderRadius: 8,
    marginHorizontal: 12,
    marginVertical: 6,
    overflow: 'hidden',
    elevation: 2,
    shadowColor: '#000',
    shadowOffset: { width: 0, height: 1 },
    shadowOpacity: 0.2,
    shadowRadius: 2,
  },
  thumbnail: {
    width: '100%',
    height: 200,
    backgroundColor: '#e0e0e0',
  },
  info: {
    padding: 12,
  },
  title: {
    fontSize: 16,
    fontWeight: '600',
    color: '#212121',
    marginBottom: 4,
  },
  channel: {
    fontSize: 14,
    color: '#616161',
    marginBottom: 4,
  },
  date: {
    fontSize: 12,
    color: '#757575',
  },
  location: {
    fontSize: 12,
    color: '#4285F4',
    marginTop: 2,
  },
  coords: {
    fontSize: 11,
    color: '#9e9e9e',
  },
  tagsRow: {
    flexDirection: 'row',
    flexWrap: 'wrap',
    marginTop: 6,
    gap: 4,
  },
  tag: {
    backgroundColor: '#e3f2fd',
    borderRadius: 12,
    paddingHorizontal: 8,
    paddingVertical: 2,
  },
  tagText: {
    fontSize: 11,
    color: '#1565c0',
  },
  moreTag: {
    fontSize: 11,
    color: '#757575',
    alignSelf: 'center',
    marginLeft: 4,
  },
});
