import { useEffect, useMemo, useState } from 'react';
import {
  ActivityIndicator,
  Alert,
  FlatList,
  Linking,
  Platform,
  Pressable,
  RefreshControl,
  SafeAreaView,
  StatusBar,
  StyleSheet,
  Text,
  View,
} from 'react-native';
import { useRouter } from 'expo-router';
import { GoogleSignin } from '@react-native-google-signin/google-signin';

import { FilterModal } from '@/components/FilterModal';
import { SortModal } from '@/components/SortModal';
import { VideoItem } from '@/components/VideoItem';
import { fetchAllVideos } from '@/services/youtubeApi';
import type { Filters, SortOptions, VideoData } from '@/types/video';

const DEFAULT_FILTERS: Filters = {
  channelName: 'All',
  country: 'All',
};

const DEFAULT_SORT: SortOptions = {
  field: 'publishedAt',
  order: 'desc',
};

export default function MainScreen() {
  const router = useRouter();
  const [allVideos, setAllVideos] = useState<VideoData[]>([]);
  const [visibleVideos, setVisibleVideos] = useState<VideoData[]>([]);
  const [isLoading, setIsLoading] = useState(true);
  const [isRefreshing, setIsRefreshing] = useState(false);
  const [filters, setFilters] = useState<Filters>(DEFAULT_FILTERS);
  const [sortOptions, setSortOptions] = useState<SortOptions>(DEFAULT_SORT);
  const [filterModalVisible, setFilterModalVisible] = useState(false);
  const [sortModalVisible, setSortModalVisible] = useState(false);
  const [errorMessage, setErrorMessage] = useState('');

  const availableChannels = useMemo(
    () => Array.from(new Set(allVideos.map((video) => video.channelName))).sort(),
    [allVideos]
  );
  const availableCountries = useMemo(
    () =>
      Array.from(
        new Set(allVideos.map((video) => video.location?.country).filter((value): value is string => !!value))
      ).sort(),
    [allVideos]
  );

  useEffect(() => {
    void loadVideos();
  }, []);

  useEffect(() => {
    const nextVideos = [...allVideos]
      .filter((video) =>
        filters.channelName === 'All' ? true : video.channelName === filters.channelName
      )
      .filter((video) =>
        filters.country === 'All' ? true : video.location?.country === filters.country
      )
      .sort((left, right) => {
        const leftValue =
          sortOptions.field === 'recordingDate'
            ? left.recordingDate ?? left.publishedAt
            : left.publishedAt;
        const rightValue =
          sortOptions.field === 'recordingDate'
            ? right.recordingDate ?? right.publishedAt
            : right.publishedAt;

        const multiplier = sortOptions.order === 'desc' ? -1 : 1;
        return leftValue.localeCompare(rightValue) * multiplier;
      });

    setVisibleVideos(nextVideos);
  }, [allVideos, filters, sortOptions]);

  async function loadVideos(forceRefresh = false) {
    if (forceRefresh) {
      setIsRefreshing(true);
    } else {
      setIsLoading(true);
    }

    setErrorMessage('');

    try {
      const videos = await fetchAllVideos(forceRefresh);
      setAllVideos(videos);
    } catch (error) {
      const message = error instanceof Error ? error.message : 'Failed to load videos.';
      setErrorMessage(message);
    } finally {
      setIsLoading(false);
      setIsRefreshing(false);
    }
  }

  async function handleLogout() {
    Alert.alert('Logout', 'Do you want to sign out?', [
      { text: 'Cancel', style: 'cancel' },
      {
        text: 'Logout',
        style: 'destructive',
        onPress: async () => {
          try {
            await GoogleSignin.signOut();
          } catch (error) {
            console.warn('Failed to sign out', error);
          } finally {
            router.replace('/login');
          }
        },
      },
    ]);
  }

  async function openVideo(video: VideoData) {
    try {
      await openYouTubeVideo(video.id, video.videoUrl);
    } catch (error) {
      console.warn('Failed to open YouTube video', error);
      Alert.alert('Unable to open video', 'Install the YouTube app or try again later.');
    }
  }

  const filtersActive = filters.channelName !== 'All' || filters.country !== 'All';

  if (isLoading) {
    return (
      <SafeAreaView style={styles.centeredScreen}>
        <ActivityIndicator size="large" color="#4285F4" />
        <Text style={styles.loadingText}>Loading videos...</Text>
      </SafeAreaView>
    );
  }

  return (
    <SafeAreaView style={styles.safeArea}>
      <StatusBar barStyle="dark-content" backgroundColor="#f7f9fc" />
      <View style={styles.container}>
        <View style={styles.header}>
          <Text style={styles.title}>YouTube Videos</Text>
          <Pressable onPress={() => void handleLogout()} style={styles.logoutButton}>
            <Text style={styles.logoutButtonText}>Logout</Text>
          </Pressable>
        </View>

        <View style={styles.controls}>
          <ControlButton
            label={filtersActive ? 'Filter (Active)' : 'Filter'}
            onPress={() => setFilterModalVisible(true)}
          />
          <ControlButton
            label={`Sort: ${sortOptions.field === 'publishedAt' ? 'Published' : 'Recorded'}`}
            onPress={() => setSortModalVisible(true)}
          />
          <ControlButton label="Refresh" variant="blue" onPress={() => void loadVideos(true)} />
          <ControlButton label="View Map" variant="green" onPress={() => router.push('/map')} />
        </View>

        <Text style={styles.statsText}>
          Showing {visibleVideos.length} of {allVideos.length} videos
        </Text>

        {visibleVideos.length === 0 ? (
          <View style={styles.emptyState}>
            <Text style={styles.emptyStateTitle}>No videos found.</Text>
            <Text style={styles.emptyStateText}>
              {errorMessage || 'Pull to refresh or verify the YouTube API key configuration.'}
            </Text>
          </View>
        ) : (
          <FlatList
            data={visibleVideos}
            keyExtractor={(item) => item.id}
            renderItem={({ item }) => <VideoItem video={item} onPress={openVideo} />}
            contentContainerStyle={styles.listContent}
            refreshControl={
              <RefreshControl
                refreshing={isRefreshing}
                onRefresh={() => void loadVideos(true)}
                tintColor="#4285F4"
              />
            }
          />
        )}
      </View>

      <FilterModal
        visible={filterModalVisible}
        filters={filters}
        channels={availableChannels}
        countries={availableCountries}
        onClose={() => setFilterModalVisible(false)}
        onApply={(nextFilters) => {
          setFilters(nextFilters);
          setFilterModalVisible(false);
        }}
      />

      <SortModal
        visible={sortModalVisible}
        sortOptions={sortOptions}
        onClose={() => setSortModalVisible(false)}
        onApply={(nextSortOptions) => {
          setSortOptions(nextSortOptions);
          setSortModalVisible(false);
        }}
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
      style={({ pressed }) => [
        styles.controlButton,
        variant === 'blue' ? styles.controlButtonBlue : null,
        variant === 'green' ? styles.controlButtonGreen : null,
        pressed ? styles.controlButtonPressed : null,
      ]}>
      <Text
        style={[
          styles.controlButtonText,
          variant === 'default' ? styles.controlButtonTextDefault : null,
        ]}>
        {label}
      </Text>
    </Pressable>
  );
}

const styles = StyleSheet.create({
  safeArea: {
    flex: 1,
    backgroundColor: '#f7f9fc',
    paddingTop: Platform.OS === 'android' ? StatusBar.currentHeight ?? 0 : 0,
  },
  centeredScreen: {
    flex: 1,
    backgroundColor: '#f7f9fc',
    alignItems: 'center',
    justifyContent: 'center',
    gap: 16,
  },
  loadingText: {
    fontSize: 16,
    color: '#475467',
  },
  container: {
    flex: 1,
    paddingHorizontal: 16,
    paddingBottom: 12,
  },
  header: {
    flexDirection: 'row',
    alignItems: 'center',
    justifyContent: 'space-between',
    marginBottom: 16,
  },
  title: {
    fontSize: 28,
    fontWeight: '700',
    color: '#101828',
  },
  logoutButton: {
    borderRadius: 12,
    backgroundColor: '#d92d20',
    paddingHorizontal: 16,
    paddingVertical: 10,
  },
  logoutButtonText: {
    color: '#ffffff',
    fontWeight: '700',
  },
  controls: {
    flexDirection: 'row',
    flexWrap: 'wrap',
    gap: 10,
    marginBottom: 12,
  },
  controlButton: {
    borderRadius: 12,
    backgroundColor: '#e4e7ec',
    paddingHorizontal: 14,
    paddingVertical: 10,
  },
  controlButtonBlue: {
    backgroundColor: '#4285F4',
  },
  controlButtonGreen: {
    backgroundColor: '#12b76a',
  },
  controlButtonPressed: {
    opacity: 0.88,
  },
  controlButtonText: {
    fontSize: 13,
    fontWeight: '600',
    color: '#ffffff',
  },
  controlButtonTextDefault: {
    color: '#101828',
  },
  statsText: {
    marginBottom: 12,
    color: '#475467',
    fontSize: 13,
  },
  listContent: {
    paddingBottom: 24,
    gap: 12,
  },
  emptyState: {
    flex: 1,
    alignItems: 'center',
    justifyContent: 'center',
    paddingHorizontal: 24,
  },
  emptyStateTitle: {
    fontSize: 20,
    fontWeight: '700',
    color: '#101828',
    marginBottom: 8,
  },
  emptyStateText: {
    fontSize: 15,
    lineHeight: 22,
    color: '#667085',
    textAlign: 'center',
  },
});

async function openYouTubeVideo(videoId: string, fallbackUrl: string) {
  const candidates =
    Platform.OS === 'android'
      ? [
          `intent://www.youtube.com/watch?v=${videoId}#Intent;package=com.google.android.youtube;scheme=https;end`,
          `vnd.youtube://${videoId}`,
          `vnd.youtube://watch?v=${videoId}`,
          `https://www.youtube.com/watch?v=${videoId}`,
          `https://m.youtube.com/watch?v=${videoId}`,
          fallbackUrl,
        ]
      : [fallbackUrl];

  let lastError: unknown;

  for (const url of candidates) {
    try {
      await Linking.openURL(url);
      return;
    } catch (error) {
      lastError = error;
    }
  }

  throw lastError ?? new Error('No supported YouTube URL could be opened.');
}
