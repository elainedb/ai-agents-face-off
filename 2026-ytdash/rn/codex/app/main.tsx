import { router } from 'expo-router';
import { useEffect, useState } from 'react';
import {
  ActivityIndicator,
  Alert,
  FlatList,
  Linking,
  Platform,
  Pressable,
  RefreshControl,
  StyleSheet,
  Text,
  View,
} from 'react-native';
import { SafeAreaView } from 'react-native-safe-area-context';

import type { Video } from '@/src/features/videos/domain/entities/video';
import { useAuthStore } from '@/src/features/authentication/presentation/stores/auth-store';
import { FilterModal } from '@/src/features/videos/presentation/components/FilterModal';
import { SortModal } from '@/src/features/videos/presentation/components/SortModal';
import { VideoItem } from '@/src/features/videos/presentation/components/VideoItem';
import { useVideosStore } from '@/src/features/videos/presentation/stores/videos-store';

const openVideo = async (videoId: string): Promise<void> => {
  const appUrl =
    Platform.OS === 'android'
      ? `vnd.youtube://watch?v=${videoId}`
      : `youtube://www.youtube.com/watch?v=${videoId}`;
  const browserUrl = `https://www.youtube.com/watch?v=${videoId}`;

  if (await Linking.canOpenURL(appUrl)) {
    await Linking.openURL(appUrl);
    return;
  }

  await Linking.openURL(browserUrl);
};

export default function MainScreen() {
  const { signOut } = useAuthStore();
  const {
    status,
    allVideos,
    filteredVideos,
    filters,
    sortOptions,
    availableChannels,
    availableCountries,
    isRefreshing,
    errorMessage,
    loadVideos,
    refreshVideos,
    filterByChannel,
    filterByCountry,
    sortVideos,
    clearFilters,
  } = useVideosStore();
  const [isFilterVisible, setIsFilterVisible] = useState(false);
  const [isSortVisible, setIsSortVisible] = useState(false);

  useEffect(() => {
    if (status === 'initial') {
      void loadVideos();
    }
  }, [loadVideos, status]);

  const filtersActive = Boolean(filters.channelName || filters.country);

  const renderItem = ({ item }: { item: Video }) => <VideoItem video={item} onPress={(video) => void openVideo(video.id)} />;

  return (
    <SafeAreaView style={styles.safeArea}>
      <View style={styles.container}>
        <View style={styles.header}>
          <Text style={styles.title}>YouTube Videos</Text>
          <Pressable
            style={styles.logoutButton}
            onPress={() => {
              Alert.alert('Logout', 'Do you want to sign out?', [
                { text: 'Cancel', style: 'cancel' },
                {
                  text: 'Logout',
                  style: 'destructive',
                  onPress: () => {
                    void signOut().then(() => {
                      router.replace('/login');
                    });
                  },
                },
              ]);
            }}>
            <Text style={styles.logoutButtonText}>Logout</Text>
          </Pressable>
        </View>

        <View style={styles.controls}>
          <Pressable style={styles.controlButton} onPress={() => setIsFilterVisible(true)}>
            <Text style={styles.controlLabel}>Filter{filtersActive ? ' (Active)' : ''}</Text>
          </Pressable>
          <Pressable style={styles.controlButton} onPress={() => setIsSortVisible(true)}>
            <Text style={styles.controlLabel}>
              Sort ({sortOptions.sortBy === 'publishedAt' ? 'Published' : 'Recorded'})
            </Text>
          </Pressable>
          <Pressable style={[styles.controlButton, styles.refreshButton]} onPress={() => void refreshVideos()}>
            <Text style={styles.primaryButtonText}>Refresh</Text>
          </Pressable>
          <Pressable style={[styles.controlButton, styles.mapButton]} onPress={() => router.push('/map')}>
            <Text style={styles.primaryButtonText}>View Map</Text>
          </Pressable>
        </View>

        {filtersActive ? (
          <Text style={styles.countText}>
            Showing {filteredVideos.length} of {allVideos.length} videos
          </Text>
        ) : null}

        {status === 'loading' ? (
          <View style={styles.centered}>
            <ActivityIndicator size="large" color="#4285F4" />
            <Text style={styles.loadingText}>Loading videos...</Text>
          </View>
        ) : null}

        {status === 'error' ? (
          <View style={styles.centered}>
            <Text style={styles.errorText}>{errorMessage}</Text>
            <Pressable style={styles.retryButton} onPress={() => void loadVideos()}>
              <Text style={styles.retryButtonText}>Retry</Text>
            </Pressable>
          </View>
        ) : null}

        {status === 'loaded' ? (
          <FlatList
            data={filteredVideos}
            keyExtractor={(item) => item.id}
            renderItem={renderItem}
            contentContainerStyle={filteredVideos.length === 0 ? styles.emptyList : styles.list}
            refreshControl={<RefreshControl refreshing={isRefreshing} onRefresh={() => void refreshVideos()} />}
            ListEmptyComponent={
              <View style={styles.centered}>
                <Text style={styles.emptyText}>No videos found. Pull to refresh or verify the API key.</Text>
              </View>
            }
          />
        ) : null}

        <FilterModal
          visible={isFilterVisible}
          filters={filters}
          channels={availableChannels}
          countries={availableCountries}
          onClose={() => setIsFilterVisible(false)}
          onApply={(nextFilters) => {
            filterByChannel(nextFilters.channelName);
            filterByCountry(nextFilters.country);
          }}
          onClear={clearFilters}
        />

        <SortModal
          visible={isSortVisible}
          sortOptions={sortOptions}
          onClose={() => setIsSortVisible(false)}
          onApply={(sortBy, sortOrder) => sortVideos(sortBy, sortOrder)}
        />
      </View>
    </SafeAreaView>
  );
}

const styles = StyleSheet.create({
  safeArea: {
    flex: 1,
    backgroundColor: '#EEF3FB',
  },
  container: {
    flex: 1,
    backgroundColor: '#EEF3FB',
    paddingHorizontal: 16,
    paddingTop: Platform.OS === 'android' ? 8 : 0,
  },
  header: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'center',
    marginVertical: 12,
    gap: 12,
  },
  title: {
    flex: 1,
    fontSize: 28,
    fontWeight: '800',
    color: '#14213D',
  },
  logoutButton: {
    backgroundColor: '#D32F2F',
    borderRadius: 14,
    paddingHorizontal: 16,
    paddingVertical: 10,
  },
  logoutButtonText: {
    color: '#FFFFFF',
    fontWeight: '700',
  },
  controls: {
    flexDirection: 'row',
    flexWrap: 'wrap',
    gap: 10,
    marginBottom: 12,
  },
  controlButton: {
    borderRadius: 14,
    backgroundColor: '#FFFFFF',
    paddingHorizontal: 14,
    paddingVertical: 12,
    borderWidth: 1,
    borderColor: '#D3DDED',
  },
  controlLabel: {
    color: '#22304A',
    fontWeight: '700',
  },
  refreshButton: {
    backgroundColor: '#4285F4',
    borderColor: '#4285F4',
  },
  mapButton: {
    backgroundColor: '#2E9E62',
    borderColor: '#2E9E62',
  },
  primaryButtonText: {
    color: '#FFFFFF',
    fontWeight: '700',
  },
  countText: {
    color: '#51627F',
    marginBottom: 12,
  },
  list: {
    paddingBottom: 24,
  },
  emptyList: {
    flexGrow: 1,
    justifyContent: 'center',
    paddingBottom: 24,
  },
  centered: {
    flex: 1,
    alignItems: 'center',
    justifyContent: 'center',
    paddingHorizontal: 24,
  },
  loadingText: {
    marginTop: 12,
    color: '#22304A',
  },
  errorText: {
    color: '#D32F2F',
    textAlign: 'center',
    marginBottom: 16,
  },
  retryButton: {
    backgroundColor: '#4285F4',
    borderRadius: 14,
    paddingHorizontal: 18,
    paddingVertical: 12,
  },
  retryButtonText: {
    color: '#FFFFFF',
    fontWeight: '700',
  },
  emptyText: {
    textAlign: 'center',
    color: '#51627F',
    lineHeight: 22,
  },
});
