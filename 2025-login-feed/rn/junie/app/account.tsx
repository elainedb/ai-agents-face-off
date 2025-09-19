import React, { useEffect, useMemo, useState } from 'react';
import { View, Text, FlatList, Image, TouchableOpacity, StyleSheet, ActivityIndicator, Linking, RefreshControl } from 'react-native';
import { fetchCombinedChannelVideos, formatDateYYYYMMDD, YoutubeVideo } from '../utils/youtube';

const CHANNEL_IDS = [
  'UCynoa1DjwnvHAowA_jiMEAQ',
  'UCK0KOjX3beyB9nzonls0cuw',
  'UCACkIrvrGAQ7kuc0hMVwvmA',
  'UCtWRAKKvOEA0CXOue9BG8ZA',
];

export default function MainScreen() {
  const [videos, setVideos] = useState<YoutubeVideo[]>([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);
  const [refreshing, setRefreshing] = useState(false);

  const load = async () => {
    setError(null);
    try {
      const data = await fetchCombinedChannelVideos(CHANNEL_IDS, 10);
      setVideos(data);
    } catch (e: any) {
      setError(e?.message || 'Failed to load videos.');
    } finally {
      setLoading(false);
      setRefreshing(false);
    }
  };

  useEffect(() => {
    load();
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, []);

  const onRefresh = async () => {
    setRefreshing(true);
    await load();
  };

  const renderItem = ({ item }: { item: YoutubeVideo }) => (
    <TouchableOpacity style={styles.card} onPress={() => Linking.openURL(`https://www.youtube.com/watch?v=${item.id}`)}>
      {!!item.thumbnailUrl && (
        <Image source={{ uri: item.thumbnailUrl }} style={styles.thumbnail} resizeMode="cover" />
      )}
      <View style={styles.meta}>
        <Text style={styles.title} numberOfLines={2}>{item.title}</Text>
        <Text style={styles.sub}>{item.channelTitle}</Text>
        <Text style={styles.date}>{formatDateYYYYMMDD(item.publishedAt)}</Text>
      </View>
    </TouchableOpacity>
  );

  const keyExtractor = (item: YoutubeVideo) => item.id;

  if (loading) {
    return (
      <View style={styles.center}>
        <ActivityIndicator />
        <Text style={styles.loadingText}>Loading videos…</Text>
      </View>
    );
  }

  return (
    <View style={styles.container}>
      {error && <Text style={styles.error}>{error}</Text>}
      <FlatList
        data={videos}
        keyExtractor={keyExtractor}
        renderItem={renderItem}
        refreshControl={<RefreshControl refreshing={refreshing} onRefresh={onRefresh} />}
        contentContainerStyle={videos.length === 0 ? styles.emptyContainer : undefined}
        ListEmptyComponent={!loading ? <Text style={styles.empty}>No videos found.</Text> : null}
      />
    </View>
  );
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
  },
  center: {
    flex: 1,
    alignItems: 'center',
    justifyContent: 'center',
    padding: 16,
  },
  loadingText: {
    marginTop: 8,
  },
  error: {
    color: 'red',
    textAlign: 'center',
    padding: 8,
  },
  emptyContainer: {
    flexGrow: 1,
    justifyContent: 'center',
    alignItems: 'center',
  },
  empty: {
    color: '#666',
  },
  card: {
    flexDirection: 'row',
    padding: 12,
    borderBottomWidth: StyleSheet.hairlineWidth,
    borderBottomColor: '#ddd',
    gap: 12,
  },
  thumbnail: {
    width: 120,
    height: 68,
    borderRadius: 4,
    backgroundColor: '#eee',
  },
  meta: {
    flex: 1,
    gap: 4,
  },
  title: {
    fontSize: 16,
    fontWeight: '600',
  },
  sub: {
    fontSize: 12,
    color: '#666',
  },
  date: {
    fontSize: 12,
    color: '#999',
  },
});
