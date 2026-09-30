import React, { useEffect, useMemo, useState } from 'react';
import { View, Text, FlatList, Image, TouchableOpacity, StyleSheet, ActivityIndicator, Linking, RefreshControl, Button } from 'react-native';
import { SafeAreaView } from 'react-native-safe-area-context';
import { useRouter } from 'expo-router';
import { fetchCombinedChannelVideosCached, formatDateYYYYMMDD, YoutubeVideo } from '../utils/youtube';

const CHANNEL_IDS = [
  'UCynoa1DjwnvHAowA_jiMEAQ',
  'UCK0KOjX3beyB9nzonls0cuw',
  'UCACkIrvrGAQ7kuc0hMVwvmA',
  'UCtWRAKKvOEA0CXOue9BG8ZA',
];

type SortField = 'publishedAt' | 'recordingDate';

type SortOrder = 'asc' | 'desc';

export default function MainScreen() {
  const router = useRouter();
  const [videos, setVideos] = useState<YoutubeVideo[]>([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);
  const [refreshing, setRefreshing] = useState(false);

  // Filters and sorting
  const [filterChannel, setFilterChannel] = useState<string | null>(null);
  const [filterCountry, setFilterCountry] = useState<string | null>(null);
  const [sortField, setSortField] = useState<SortField>('publishedAt');
  const [sortOrder, setSortOrder] = useState<SortOrder>('desc');
  const [showFilter, setShowFilter] = useState(false);
  const [showSort, setShowSort] = useState(false);

  const load = async (forceRefresh = false) => {
    setError(null);
    try {
      const data = await fetchCombinedChannelVideosCached(CHANNEL_IDS, 100, { forceRefresh });
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
    await load(true);
  };

  const channelOptions = useMemo(() => {
    const set = new Set<string>();
    videos.forEach((v) => v.channelTitle && set.add(v.channelTitle));
    return Array.from(set);
  }, [videos]);

  const countryOptions = useMemo(() => {
    const set = new Set<string>();
    videos.forEach((v) => v.locationCountry && set.add(v.locationCountry));
    return Array.from(set);
  }, [videos]);

  const filteredSorted = useMemo(() => {
    let list = [...videos];
    if (filterChannel) list = list.filter((v) => v.channelTitle === filterChannel);
    if (filterCountry) list = list.filter((v) => v.locationCountry === filterCountry);

    list.sort((a, b) => {
      const aVal = sortField === 'publishedAt' ? a.publishedAt : (a.recordingDate || '');
      const bVal = sortField === 'publishedAt' ? b.publishedAt : (b.recordingDate || '');
      const aTime = aVal ? new Date(aVal).getTime() : 0;
      const bTime = bVal ? new Date(bVal).getTime() : 0;
      return sortOrder === 'desc' ? bTime - aTime : aTime - bTime;
    });

    return list;
  }, [videos, filterChannel, filterCountry, sortField, sortOrder]);

  const clearFilters = () => {
    setFilterChannel(null);
    setFilterCountry(null);
  };

  const renderItem = ({ item }: { item: YoutubeVideo }) => (
    <TouchableOpacity style={styles.card} onPress={() => Linking.openURL(`https://www.youtube.com/watch?v=${item.id}`)}>
      {!!item.thumbnailUrl && (
        <Image source={{ uri: item.thumbnailUrl }} style={styles.thumbnail} resizeMode="cover" />
      )}
      <View style={styles.meta}>
        <Text style={styles.title} numberOfLines={2}>{item.title}</Text>
        <Text style={styles.sub}>Channel: {item.channelTitle}</Text>
        <Text style={styles.sub}>Published: {formatDateYYYYMMDD(item.publishedAt)}</Text>
        {item.recordingDate && (
          <Text style={styles.sub}>Recorded: {formatDateYYYYMMDD(item.recordingDate)}</Text>
        )}
        {(item.locationCity || item.locationCountry || (item.locationLat && item.locationLng)) && (
          <Text style={styles.sub} numberOfLines={2}>
            Location: {[item.locationCity, item.locationCountry].filter(Boolean).join(', ')}
            {item.locationLat !== undefined && item.locationLng !== undefined ? ` (${item.locationLat?.toFixed(4)}, ${item.locationLng?.toFixed(4)})` : ''}
          </Text>
        )}
        {!!item.tags?.length && (
          <Text style={styles.sub} numberOfLines={2}>Tags: {item.tags.join(', ')}</Text>
        )}
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
    <SafeAreaView style={styles.container} edges={['top']}>
      {error && <Text style={styles.error}>{error}</Text>}

      {/* Controls */}
      <View style={styles.controls}>
        <Button title="View Map" onPress={() => router.push('/map')} />
        <Button title="Refresh" onPress={() => load(true)} />
        <Button title="Filter" onPress={() => setShowFilter((v) => !v)} />
        <Button title="Sort" onPress={() => setShowSort((v) => !v)} />
      </View>

      {showFilter && (
        <View style={styles.panel}>
          <Text style={styles.panelTitle}>Filter by Channel</Text>
          <View style={styles.rowWrap}>
            <TouchableOpacity style={[styles.chip, !filterChannel && styles.chipActive]} onPress={() => setFilterChannel(null)}>
              <Text style={styles.chipText}>All</Text>
            </TouchableOpacity>
            {channelOptions.map((ch) => (
              <TouchableOpacity key={ch} style={[styles.chip, filterChannel === ch && styles.chipActive]} onPress={() => setFilterChannel(ch)}>
                <Text style={styles.chipText}>{ch}</Text>
              </TouchableOpacity>
            ))}
          </View>

          <Text style={[styles.panelTitle, { marginTop: 8 }]}>Filter by Country</Text>
          <View style={styles.rowWrap}>
            <TouchableOpacity style={[styles.chip, !filterCountry && styles.chipActive]} onPress={() => setFilterCountry(null)}>
              <Text style={styles.chipText}>All</Text>
            </TouchableOpacity>
            {countryOptions.map((ct) => (
              <TouchableOpacity key={ct} style={[styles.chip, filterCountry === ct && styles.chipActive]} onPress={() => setFilterCountry(ct)}>
                <Text style={styles.chipText}>{ct}</Text>
              </TouchableOpacity>
            ))}
          </View>

          {(filterChannel || filterCountry) && (
            <View style={{ marginTop: 8 }}>
              <Button title="Clear filters" onPress={clearFilters} />
            </View>
          )}
        </View>
      )}

      {showSort && (
        <View style={styles.panel}>
          <Text style={styles.panelTitle}>Sort by</Text>
          <View style={styles.rowWrap}>
            <TouchableOpacity style={[styles.chip, sortField === 'publishedAt' && styles.chipActive]} onPress={() => setSortField('publishedAt')}>
              <Text style={styles.chipText}>Publication Date</Text>
            </TouchableOpacity>
            <TouchableOpacity style={[styles.chip, sortField === 'recordingDate' && styles.chipActive]} onPress={() => setSortField('recordingDate')}>
              <Text style={styles.chipText}>Recording Date</Text>
            </TouchableOpacity>
          </View>
          <Text style={[styles.panelTitle, { marginTop: 8 }]}>Order</Text>
          <View style={styles.rowWrap}>
            <TouchableOpacity style={[styles.chip, sortOrder === 'desc' && styles.chipActive]} onPress={() => setSortOrder('desc')}>
              <Text style={styles.chipText}>Newest → Oldest</Text>
            </TouchableOpacity>
            <TouchableOpacity style={[styles.chip, sortOrder === 'asc' && styles.chipActive]} onPress={() => setSortOrder('asc')}>
              <Text style={styles.chipText}>Oldest → Newest</Text>
            </TouchableOpacity>
          </View>
        </View>
      )}

      <View style={styles.countBar}>
        <Text style={styles.countText}>Videos: {filteredSorted.length}</Text>
      </View>

      <FlatList
        data={filteredSorted}
        keyExtractor={keyExtractor}
        renderItem={renderItem}
        refreshControl={<RefreshControl refreshing={refreshing} onRefresh={onRefresh} />}
        contentContainerStyle={filteredSorted.length === 0 ? styles.emptyContainer : undefined}
        ListEmptyComponent={!loading ? <Text style={styles.empty}>No videos found.</Text> : null}
      />
    </SafeAreaView>
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
  controls: {
    flexDirection: 'row',
    justifyContent: 'space-around',
    paddingHorizontal: 8,
    paddingVertical: 6,
    borderBottomWidth: StyleSheet.hairlineWidth,
    borderBottomColor: '#ddd',
  },
  panel: {
    paddingHorizontal: 8,
    paddingVertical: 8,
    borderBottomWidth: StyleSheet.hairlineWidth,
    borderBottomColor: '#eee',
    gap: 4,
  },
  panelTitle: {
    fontWeight: '600',
  },
  rowWrap: {
    flexDirection: 'row',
    flexWrap: 'wrap',
    gap: 8,
    alignItems: 'center',
  },
  chip: {
    paddingHorizontal: 10,
    paddingVertical: 6,
    borderRadius: 16,
    borderWidth: 1,
    borderColor: '#bbb',
  },
  chipActive: {
    backgroundColor: '#333',
    borderColor: '#333',
  },
  chipText: {
    color: '#000',
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
  countBar: {
    paddingHorizontal: 8,
    paddingVertical: 6,
    borderBottomWidth: StyleSheet.hairlineWidth,
    borderBottomColor: '#eee',
  },
  countText: {
    fontSize: 12,
    color: '#333',
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
    color: '#444',
  },
  date: {
    fontSize: 12,
    color: '#999',
  },
});
