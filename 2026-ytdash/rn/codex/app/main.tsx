import { useEffect, useMemo, useState } from 'react';
import {
  ActivityIndicator,
  Alert,
  FlatList,
  Platform,
  Pressable,
  RefreshControl,
  SafeAreaView,
  StatusBar,
  StyleSheet,
  Text,
  View,
} from 'react-native';
import { GoogleSignin } from '@react-native-google-signin/google-signin';
import { router } from 'expo-router';

import FilterModal, { type FilterState } from '@/components/FilterModal';
import SortModal, { type SortOptions } from '@/components/SortModal';
import VideoItem from '@/components/VideoItem';
import type { VideoData } from '@/services/youtubeApi';
import { fetchAllVideos } from '@/services/youtubeApi';

const defaultFilters: FilterState = {
  channel: 'All',
  country: 'All',
};

const defaultSort: SortOptions = {
  field: 'published',
  order: 'desc',
};

export default function MainScreen() {
  const [allVideos, setAllVideos] = useState<VideoData[]>([]);
  const [visibleVideos, setVisibleVideos] = useState<VideoData[]>([]);
  const [filters, setFilters] = useState<FilterState>(defaultFilters);
  const [sortOptions, setSortOptions] = useState<SortOptions>(defaultSort);
  const [loading, setLoading] = useState(true);
  const [refreshing, setRefreshing] = useState(false);
  const [filterModalVisible, setFilterModalVisible] = useState(false);
  const [sortModalVisible, setSortModalVisible] = useState(false);
  const [errorMessage, setErrorMessage] = useState('');

  const loadVideos = async (forceRefresh = false) => {
    if (forceRefresh) {
      setRefreshing(true);
    } else {
      setLoading(true);
    }

    try {
      const videos = await fetchAllVideos(forceRefresh);
      setAllVideos(videos);
      setErrorMessage('');
    } catch (error) {
      setErrorMessage(error instanceof Error ? error.message : 'Unable to load videos');
    } finally {
      setLoading(false);
      setRefreshing(false);
    }
  };

  useEffect(() => {
    void loadVideos();
  }, []);

  useEffect(() => {
    const nextVideos = [...allVideos]
      .filter((video) => filters.channel === 'All' || video.channelName === filters.channel)
      .filter((video) => filters.country === 'All' || video.location?.country === filters.country)
      .sort((left, right) => {
        const leftDate =
          sortOptions.field === 'recorded'
            ? left.recordingDate ?? left.publishedAt
            : left.publishedAt;
        const rightDate =
          sortOptions.field === 'recorded'
            ? right.recordingDate ?? right.publishedAt
            : right.publishedAt;
        const comparison = new Date(leftDate).getTime() - new Date(rightDate).getTime();
        return sortOptions.order === 'desc' ? -comparison : comparison;
      });

    setVisibleVideos(nextVideos);
  }, [allVideos, filters, sortOptions]);

  const channels = useMemo(
    () => Array.from(new Set(allVideos.map((video) => video.channelName))).sort(),
    [allVideos]
  );
  const countries = useMemo(
    () =>
      Array.from(
        new Set(allVideos.map((video) => video.location?.country).filter(Boolean) as string[])
      ).sort(),
    [allVideos]
  );

  const hasActiveFilters = filters.channel !== 'All' || filters.country !== 'All';

  const handleLogout = () => {
    Alert.alert('Logout', 'Do you want to sign out?', [
      { text: 'Cancel', style: 'cancel' },
      {
        text: 'Logout',
        style: 'destructive',
        onPress: async () => {
          await GoogleSignin.signOut();
          router.replace('/login');
        },
      },
    ]);
  };

  return (
    <SafeAreaView style={styles.safeArea}>
      <StatusBar barStyle="dark-content" />
      <View style={styles.container}>
        <View style={styles.headerRow}>
          <Text style={styles.title}>YouTube Videos</Text>
          <Pressable onPress={handleLogout} style={styles.logoutButton}>
            <Text style={styles.logoutText}>Logout</Text>
          </Pressable>
        </View>

        <View style={styles.controlsRow}>
          <ControlButton
            label={`Filter${hasActiveFilters ? ' (Active)' : ''}`}
            onPress={() => setFilterModalVisible(true)}
          />
          <ControlButton
            label={`Sort: ${sortOptions.field === 'published' ? 'Published' : 'Recorded'}`}
            onPress={() => setSortModalVisible(true)}
          />
          <ControlButton label="Refresh" onPress={() => void loadVideos(true)} variant="blue" />
          <ControlButton label="View Map" onPress={() => router.push('/map')} variant="green" />
        </View>

        <Text style={styles.stats}>Showing {visibleVideos.length} of {allVideos.length} videos</Text>

        {loading ? (
          <View style={styles.centered}>
            <ActivityIndicator color="#4285F4" size="large" />
            <Text style={styles.loadingText}>Loading videos...</Text>
          </View>
        ) : visibleVideos.length === 0 ? (
          <View style={styles.centered}>
            <Text style={styles.emptyTitle}>No videos found</Text>
            <Text style={styles.emptyBody}>
              {errorMessage || 'Pull to refresh or check your API key configuration.'}
            </Text>
          </View>
        ) : (
          <FlatList
            contentContainerStyle={styles.listContent}
            data={visibleVideos}
            keyExtractor={(item) => item.id}
            refreshControl={
              <RefreshControl refreshing={refreshing} onRefresh={() => void loadVideos(true)} />
            }
            renderItem={({ item }) => <VideoItem video={item} />}
          />
        )}
      </View>

      <FilterModal
        availableChannels={channels}
        availableCountries={countries}
        initialFilters={filters}
        onApply={(nextFilters) => {
          setFilters(nextFilters);
          setFilterModalVisible(false);
        }}
        onClose={() => setFilterModalVisible(false)}
        visible={filterModalVisible}
      />
      <SortModal
        initialSort={sortOptions}
        onApply={(nextSort) => {
          setSortOptions(nextSort);
          setSortModalVisible(false);
        }}
        onClose={() => setSortModalVisible(false)}
        visible={sortModalVisible}
      />
    </SafeAreaView>
  );
}

type ControlButtonProps = {
  label: string;
  onPress: () => void;
  variant?: 'default' | 'blue' | 'green';
};

function ControlButton({ label, onPress, variant = 'default' }: ControlButtonProps) {
  return (
    <Pressable
      onPress={onPress}
      style={[styles.controlButton, variant === 'blue' && styles.blueButton, variant === 'green' && styles.greenButton]}>
      <Text style={[styles.controlText, variant !== 'default' && styles.lightControlText]}>{label}</Text>
    </Pressable>
  );
}

const styles = StyleSheet.create({
  safeArea: {
    flex: 1,
    backgroundColor: '#f7f9fc',
    paddingTop: Platform.OS === 'android' ? StatusBar.currentHeight ?? 0 : 0,
  },
  container: {
    flex: 1,
    paddingHorizontal: 16,
    paddingTop: 12,
  },
  headerRow: {
    alignItems: 'center',
    flexDirection: 'row',
    justifyContent: 'space-between',
    marginBottom: 12,
  },
  title: {
    color: '#14213d',
    fontSize: 28,
    fontWeight: '700',
  },
  logoutButton: {
    backgroundColor: '#d62828',
    borderRadius: 12,
    paddingHorizontal: 16,
    paddingVertical: 10,
  },
  logoutText: {
    color: '#ffffff',
    fontWeight: '600',
  },
  controlsRow: {
    flexDirection: 'row',
    flexWrap: 'wrap',
    gap: 8,
    marginBottom: 12,
  },
  controlButton: {
    backgroundColor: '#e7ecf3',
    borderRadius: 12,
    paddingHorizontal: 12,
    paddingVertical: 10,
  },
  blueButton: {
    backgroundColor: '#4285F4',
  },
  greenButton: {
    backgroundColor: '#2a9d8f',
  },
  controlText: {
    color: '#22304a',
    fontSize: 13,
    fontWeight: '600',
  },
  lightControlText: {
    color: '#ffffff',
  },
  stats: {
    color: '#52627a',
    fontSize: 14,
    marginBottom: 12,
  },
  centered: {
    alignItems: 'center',
    flex: 1,
    justifyContent: 'center',
    paddingHorizontal: 24,
  },
  loadingText: {
    color: '#52627a',
    fontSize: 16,
    marginTop: 12,
  },
  emptyTitle: {
    color: '#14213d',
    fontSize: 20,
    fontWeight: '700',
    marginBottom: 8,
    textAlign: 'center',
  },
  emptyBody: {
    color: '#52627a',
    fontSize: 15,
    textAlign: 'center',
  },
  listContent: {
    paddingBottom: 24,
  },
});
