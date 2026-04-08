import { useEffect, useState } from 'react';
import {
  ActivityIndicator,
  Alert,
  FlatList,
  Pressable,
  RefreshControl,
  SafeAreaView,
  StyleSheet,
  Text,
  View,
} from 'react-native';
import { router } from 'expo-router';

import { getContainer } from '@/src/core/di/container';
import { FilterModal } from '@/src/features/videos/presentation/components/FilterModal';
import { SortModal } from '@/src/features/videos/presentation/components/SortModal';
import { VideoItem } from '@/src/features/videos/presentation/components/VideoItem';

export default function MainScreen() {
  const { authStore, videosStore } = getContainer();
  const [filterVisible, setFilterVisible] = useState(false);
  const [sortVisible, setSortVisible] = useState(false);

  const authStatus = authStore((state) => state.status);

  const status = videosStore((state) => state.status);
  const allVideos = videosStore((state) => state.allVideos);
  const filteredVideos = videosStore((state) => state.filteredVideos);
  const filters = videosStore((state) => state.filters);
  const sortOptions = videosStore((state) => state.sortOptions);
  const isRefreshing = videosStore((state) => state.isRefreshing);
  const errorMessage = videosStore((state) => state.errorMessage);
  const availableChannels = videosStore((state) => state.availableChannels);
  const availableCountries = videosStore((state) => state.availableCountries);
  const clearFilters = videosStore((state) => state.clearFilters);

  useEffect(() => {
    if (authStatus === 'unauthenticated') {
      router.replace('/login');
    }
  }, [authStatus]);

  useEffect(() => {
    if (status === 'initial') {
      void videosStore.getState().loadVideos();
    }
  }, [status, videosStore]);

  const hasActiveFilters = Boolean(filters.channelName || filters.country);

  const handleLogout = () => {
    Alert.alert('Logout', 'Sign out of this device?', [
      { text: 'Cancel', style: 'cancel' },
      {
        text: 'Logout',
        style: 'destructive',
        onPress: () => {
          void authStore.getState().signOut().then(() => router.replace('/login'));
        },
      },
    ]);
  };

  if (status === 'loading') {
    return (
      <SafeAreaView style={styles.stateScreen}>
        <ActivityIndicator size="large" color="#4285F4" />
        <Text style={styles.stateText}>Loading videos...</Text>
      </SafeAreaView>
    );
  }

  if (status === 'error') {
    return (
      <SafeAreaView style={styles.stateScreen}>
        <Text style={styles.errorTitle}>Unable to load videos</Text>
        <Text style={styles.stateText}>{errorMessage}</Text>
        <Pressable style={styles.retryButton} onPress={() => void videosStore.getState().loadVideos()}>
          <Text style={styles.retryButtonText}>Retry</Text>
        </Pressable>
      </SafeAreaView>
    );
  }

  return (
    <SafeAreaView style={styles.container}>
      <View style={styles.header}>
        <View>
          <Text style={styles.headerTitle}>YouTube Videos</Text>
          <Text style={styles.headerSubtitle}>Latest uploads from the configured channels</Text>
        </View>
        <Pressable style={styles.logoutButton} onPress={handleLogout}>
          <Text style={styles.logoutText}>Logout</Text>
        </Pressable>
      </View>

      <View style={styles.controls}>
        <Pressable style={styles.controlButton} onPress={() => setFilterVisible(true)}>
          <Text style={styles.controlText}>
            Filter {hasActiveFilters ? '(Active)' : ''}
          </Text>
        </Pressable>
        <Pressable style={styles.controlButton} onPress={() => setSortVisible(true)}>
          <Text style={styles.controlText}>
            Sort {sortOptions.sortBy === 'publishedDate' ? 'Published' : 'Recorded'}
          </Text>
        </Pressable>
        <Pressable
          style={[styles.controlButton, styles.refreshButton]}
          onPress={() => void videosStore.getState().refreshVideos()}>
          <Text style={[styles.controlText, styles.controlTextLight]}>Refresh</Text>
        </Pressable>
        <Pressable style={[styles.controlButton, styles.mapButton]} onPress={() => router.push('/map')}>
          <Text style={[styles.controlText, styles.controlTextLight]}>View Map</Text>
        </Pressable>
      </View>

      <Text style={styles.videoCount}>
        {hasActiveFilters
          ? `Showing ${filteredVideos.length} of ${allVideos.length} videos`
          : `Showing ${filteredVideos.length} videos`}
      </Text>

      <FlatList
        data={filteredVideos}
        keyExtractor={(item) => item.id}
        renderItem={({ item }) => <VideoItem video={item} />}
        contentContainerStyle={filteredVideos.length === 0 ? styles.emptyList : styles.list}
        refreshControl={
          <RefreshControl
            refreshing={isRefreshing}
            onRefresh={() => void videosStore.getState().refreshVideos()}
          />
        }
        ListEmptyComponent={
          <View style={styles.emptyState}>
            <Text style={styles.emptyTitle}>No videos available</Text>
            <Text style={styles.emptyText}>
              Pull to refresh, or confirm the YouTube API key is valid.
            </Text>
          </View>
        }
      />

      <FilterModal
        visible={filterVisible}
        filters={filters}
        availableChannels={availableChannels}
        availableCountries={availableCountries}
        onClose={() => setFilterVisible(false)}
        onClear={clearFilters}
        onApply={(nextFilters) => {
          videosStore.getState().filterByChannel(nextFilters.channelName);
          videosStore.getState().filterByCountry(nextFilters.country);
        }}
      />

      <SortModal
        visible={sortVisible}
        sortOptions={sortOptions}
        onClose={() => setSortVisible(false)}
        onApply={(sortBy, sortOrder) => videosStore.getState().sortVideos(sortBy, sortOrder)}
      />
    </SafeAreaView>
  );
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: '#f4f7ff',
    paddingHorizontal: 16,
    paddingTop: 12,
  },
  header: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'flex-start',
    gap: 12,
    marginBottom: 16,
  },
  headerTitle: {
    fontSize: 28,
    fontWeight: '800',
    color: '#13203a',
  },
  headerSubtitle: {
    color: '#5b6e91',
    marginTop: 4,
  },
  logoutButton: {
    backgroundColor: '#d32f2f',
    borderRadius: 14,
    paddingHorizontal: 14,
    paddingVertical: 10,
  },
  logoutText: {
    color: '#ffffff',
    fontWeight: '700',
  },
  controls: {
    flexDirection: 'row',
    flexWrap: 'wrap',
    gap: 10,
    marginBottom: 10,
  },
  controlButton: {
    paddingHorizontal: 14,
    paddingVertical: 12,
    borderRadius: 14,
    backgroundColor: '#ffffff',
    borderWidth: 1,
    borderColor: '#d5e0f7',
  },
  refreshButton: {
    backgroundColor: '#4285F4',
    borderColor: '#4285F4',
  },
  mapButton: {
    backgroundColor: '#1c9b5f',
    borderColor: '#1c9b5f',
  },
  controlText: {
    color: '#304567',
    fontWeight: '700',
  },
  controlTextLight: {
    color: '#ffffff',
  },
  videoCount: {
    color: '#5b6e91',
    marginBottom: 12,
    fontWeight: '600',
  },
  list: {
    paddingBottom: 24,
  },
  emptyList: {
    flexGrow: 1,
    justifyContent: 'center',
  },
  emptyState: {
    alignItems: 'center',
    gap: 10,
    paddingHorizontal: 24,
  },
  emptyTitle: {
    fontSize: 22,
    fontWeight: '800',
    color: '#1b2a45',
  },
  emptyText: {
    textAlign: 'center',
    color: '#607192',
    lineHeight: 21,
  },
  stateScreen: {
    flex: 1,
    alignItems: 'center',
    justifyContent: 'center',
    gap: 12,
    padding: 24,
    backgroundColor: '#f4f7ff',
  },
  stateText: {
    color: '#5b6e91',
    textAlign: 'center',
  },
  errorTitle: {
    color: '#13203a',
    fontWeight: '800',
    fontSize: 22,
  },
  retryButton: {
    backgroundColor: '#4285F4',
    borderRadius: 14,
    paddingHorizontal: 20,
    paddingVertical: 12,
  },
  retryButtonText: {
    color: '#ffffff',
    fontWeight: '700',
  },
});
