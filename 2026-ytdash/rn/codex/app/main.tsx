import { useEffect, useMemo, useState } from 'react';
import {
  ActivityIndicator,
  Alert,
  FlatList,
  RefreshControl,
  SafeAreaView,
  StatusBar,
  StyleSheet,
  Text,
  TouchableOpacity,
  View,
} from 'react-native';
import { GoogleSignin } from '@react-native-google-signin/google-signin';
import { useRouter } from 'expo-router';

import { FilterModal, type Filters } from '@/components/FilterModal';
import { SortModal, type SortOptions } from '@/components/SortModal';
import { VideoItem } from '@/components/VideoItem';
import { fetchAllVideos, type VideoData } from '@/services/youtubeApi';

const initialFilters: Filters = {
  channelName: 'All',
  country: 'All',
};

const initialSortOptions: SortOptions = {
  field: 'published',
  order: 'desc',
};

export default function MainScreen() {
  const router = useRouter();
  const [allVideos, setAllVideos] = useState<VideoData[]>([]);
  const [visibleVideos, setVisibleVideos] = useState<VideoData[]>([]);
  const [loading, setLoading] = useState(true);
  const [refreshing, setRefreshing] = useState(false);
  const [error, setError] = useState('');
  const [filters, setFilters] = useState<Filters>(initialFilters);
  const [sortOptions, setSortOptions] = useState<SortOptions>(initialSortOptions);
  const [filterVisible, setFilterVisible] = useState(false);
  const [sortVisible, setSortVisible] = useState(false);

  const loadVideos = async (forceRefresh = false) => {
    if (forceRefresh) {
      setRefreshing(true);
    } else {
      setLoading(true);
    }

    try {
      const videos = await fetchAllVideos(forceRefresh);
      setAllVideos(videos);
      setError('');
    } catch (loadError) {
      console.log('Failed to load videos', loadError);
      setError('Unable to load videos. Pull to refresh or verify the YouTube API key.');
    } finally {
      setLoading(false);
      setRefreshing(false);
    }
  };

  useEffect(() => {
    void loadVideos();
  }, []);

  useEffect(() => {
    const filteredVideos = allVideos.filter((video) => {
      const channelMatches = filters.channelName === 'All' || video.channelName === filters.channelName;
      const countryMatches = filters.country === 'All' || video.location?.country === filters.country;
      return channelMatches && countryMatches;
    });

    const sortedVideos = [...filteredVideos].sort((left, right) => {
      const leftDate =
        sortOptions.field === 'recorded'
          ? left.recordingDate ?? left.publishedAt
          : left.publishedAt;
      const rightDate =
        sortOptions.field === 'recorded'
          ? right.recordingDate ?? right.publishedAt
          : right.publishedAt;

      const comparison = new Date(leftDate).getTime() - new Date(rightDate).getTime();
      return sortOptions.order === 'asc' ? comparison : comparison * -1;
    });

    setVisibleVideos(sortedVideos);
  }, [allVideos, filters, sortOptions]);

  const channelOptions = useMemo(
    () => Array.from(new Set(allVideos.map((video) => video.channelName))).sort((a, b) => a.localeCompare(b)),
    [allVideos]
  );
  const countryOptions = useMemo(
    () =>
      Array.from(
        new Set(allVideos.map((video) => video.location?.country).filter((country): country is string => Boolean(country)))
      ).sort((a, b) => a.localeCompare(b)),
    [allVideos]
  );

  const handleLogout = () => {
    Alert.alert('Logout', 'Sign out from this Google account?', [
      { text: 'Cancel', style: 'cancel' },
      {
        text: 'Logout',
        style: 'destructive',
        onPress: async () => {
          await GoogleSignin.signOut().catch(() => undefined);
          router.replace('/login');
        },
      },
    ]);
  };

  const filtersActive = filters.channelName !== 'All' || filters.country !== 'All';

  return (
    <SafeAreaView style={styles.container}>
      <StatusBar barStyle="dark-content" backgroundColor="#ffffff" />

      <View style={styles.header}>
        <Text style={styles.title}>YouTube Videos</Text>
        <TouchableOpacity onPress={handleLogout} style={styles.logoutButton}>
          <Text style={styles.logoutText}>Logout</Text>
        </TouchableOpacity>
      </View>

      <View style={styles.controlsRow}>
        <TouchableOpacity onPress={() => setFilterVisible(true)} style={styles.controlButton}>
          <Text style={styles.controlText}>Filter{filtersActive ? ' (Active)' : ''}</Text>
        </TouchableOpacity>

        <TouchableOpacity onPress={() => setSortVisible(true)} style={styles.controlButton}>
          <Text style={styles.controlText}>
            Sort: {sortOptions.field === 'published' ? 'Published' : 'Recorded'}
          </Text>
        </TouchableOpacity>
      </View>

      <View style={styles.controlsRow}>
        <TouchableOpacity onPress={() => void loadVideos(true)} style={[styles.controlButton, styles.refreshButton]}>
          <Text style={[styles.controlText, styles.whiteText]}>Refresh</Text>
        </TouchableOpacity>

        <TouchableOpacity onPress={() => router.push('/map')} style={[styles.controlButton, styles.mapButton]}>
          <Text style={[styles.controlText, styles.whiteText]}>View Map</Text>
        </TouchableOpacity>
      </View>

      <Text style={styles.statsText}>Showing {visibleVideos.length} of {allVideos.length} videos</Text>

      {loading ? (
        <View style={styles.centerState}>
          <ActivityIndicator color="#4285F4" size="large" />
          <Text style={styles.stateText}>Loading videos...</Text>
        </View>
      ) : visibleVideos.length === 0 ? (
        <View style={styles.centerState}>
          <Text style={styles.emptyTitle}>No videos found</Text>
          <Text style={styles.stateText}>
            {error || 'Pull to refresh or verify the configured API key and channel data.'}
          </Text>
        </View>
      ) : (
        <FlatList
          contentContainerStyle={styles.listContent}
          data={visibleVideos}
          keyExtractor={(item) => item.id}
          refreshControl={<RefreshControl refreshing={refreshing} onRefresh={() => void loadVideos(true)} />}
          renderItem={({ item }) => <VideoItem video={item} />}
        />
      )}

      <FilterModal
        channelOptions={channelOptions}
        countryOptions={countryOptions}
        filters={filters}
        onApply={setFilters}
        onClose={() => setFilterVisible(false)}
        visible={filterVisible}
      />

      <SortModal
        onApply={setSortOptions}
        onClose={() => setSortVisible(false)}
        sortOptions={sortOptions}
        visible={sortVisible}
      />
    </SafeAreaView>
  );
}

const styles = StyleSheet.create({
  container: {
    backgroundColor: '#ffffff',
    flex: 1,
    paddingTop: StatusBar.currentHeight ?? 0,
  },
  header: {
    alignItems: 'center',
    flexDirection: 'row',
    justifyContent: 'space-between',
    paddingHorizontal: 16,
    paddingVertical: 14,
  },
  title: {
    color: '#111827',
    fontSize: 28,
    fontWeight: '700',
  },
  logoutButton: {
    backgroundColor: '#d32f2f',
    borderRadius: 10,
    paddingHorizontal: 14,
    paddingVertical: 10,
  },
  logoutText: {
    color: '#ffffff',
    fontWeight: '600',
  },
  controlsRow: {
    flexDirection: 'row',
    gap: 12,
    paddingHorizontal: 16,
    paddingTop: 8,
  },
  controlButton: {
    alignItems: 'center',
    backgroundColor: '#eef2ff',
    borderRadius: 10,
    flex: 1,
    justifyContent: 'center',
    minHeight: 46,
    paddingHorizontal: 10,
  },
  refreshButton: {
    backgroundColor: '#1d4ed8',
  },
  mapButton: {
    backgroundColor: '#15803d',
  },
  controlText: {
    color: '#1f2937',
    fontSize: 14,
    fontWeight: '600',
    textAlign: 'center',
  },
  whiteText: {
    color: '#ffffff',
  },
  statsText: {
    color: '#4b5563',
    fontSize: 14,
    paddingHorizontal: 16,
    paddingTop: 14,
  },
  centerState: {
    alignItems: 'center',
    flex: 1,
    justifyContent: 'center',
    paddingHorizontal: 24,
  },
  emptyTitle: {
    color: '#111827',
    fontSize: 20,
    fontWeight: '700',
    marginBottom: 12,
  },
  stateText: {
    color: '#6b7280',
    fontSize: 15,
    marginTop: 12,
    textAlign: 'center',
  },
  listContent: {
    padding: 16,
    paddingBottom: 32,
  },
});
