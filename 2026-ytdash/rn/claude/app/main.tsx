import { useEffect, useState, useCallback, useMemo } from 'react';
import {
  View,
  Text,
  FlatList,
  StyleSheet,
  TouchableOpacity,
  ActivityIndicator,
  RefreshControl,
  SafeAreaView,
  Platform,
  StatusBar,
  Alert,
} from 'react-native';
import { router } from 'expo-router';
import { useAuthStore } from '@/src/features/authentication/presentation/stores/auth-store';
import { useVideosStore } from '@/src/features/videos/presentation/stores/videos-store';
import { VideoItem } from '@/src/features/videos/presentation/components/VideoItem';
import { FilterModal } from '@/src/features/videos/presentation/components/FilterModal';
import { SortModal } from '@/src/features/videos/presentation/components/SortModal';

export default function MainScreen() {
  const { signOut: authSignOut } = useAuthStore();
  const {
    status,
    filteredVideos,
    allVideos,
    filters,
    sortOptions,
    isRefreshing,
    errorMessage,
    loadVideos,
    refreshVideos,
    filterByChannel,
    filterByCountry,
    sortVideos,
  } = useVideosStore();

  const channels = useMemo(
    () => [...new Set(allVideos.map((v) => v.channelName))].sort(),
    [allVideos],
  );
  const countries = useMemo(
    () => [...new Set(allVideos.filter((v) => v.country).map((v) => v.country!))].sort(),
    [allVideos],
  );

  const [filterModalVisible, setFilterModalVisible] = useState(false);
  const [sortModalVisible, setSortModalVisible] = useState(false);

  useEffect(() => {
    loadVideos();
  }, []);

  const handleLogout = () => {
    Alert.alert('Logout', 'Are you sure you want to log out?', [
      { text: 'Cancel', style: 'cancel' },
      {
        text: 'Logout',
        style: 'destructive',
        onPress: async () => {
          await authSignOut();
          router.replace('/login');
        },
      },
    ]);
  };

  const handleFilterApply = (channelName: string | null, country: string | null) => {
    filterByChannel(channelName);
    filterByCountry(country);
  };

  const hasActiveFilters = filters.channelName !== null || filters.country !== null;

  const onRefresh = useCallback(() => {
    refreshVideos();
  }, [refreshVideos]);

  if (status === 'loading' && !isRefreshing) {
    return (
      <SafeAreaView style={styles.container}>
        <View style={styles.centered}>
          <ActivityIndicator size="large" color="#4285F4" />
          <Text style={styles.loadingText}>Loading videos...</Text>
        </View>
      </SafeAreaView>
    );
  }

  return (
    <SafeAreaView style={styles.container}>
      <View style={styles.header}>
        <Text style={styles.headerTitle}>YouTube Videos</Text>
        <TouchableOpacity onPress={handleLogout}>
          <Text style={styles.logoutButton}>Logout</Text>
        </TouchableOpacity>
      </View>

      <View style={styles.controls}>
        <TouchableOpacity
          style={styles.controlButton}
          onPress={() => setFilterModalVisible(true)}
        >
          <Text style={styles.controlButtonText}>
            Filter{hasActiveFilters ? ' (Active)' : ''}
          </Text>
        </TouchableOpacity>
        <TouchableOpacity
          style={styles.controlButton}
          onPress={() => setSortModalVisible(true)}
        >
          <Text style={styles.controlButtonText}>
            Sort: {sortOptions.sortBy === 'publishedDate' ? 'Published' : 'Recorded'}
          </Text>
        </TouchableOpacity>
        <TouchableOpacity
          style={[styles.controlButton, styles.refreshButton]}
          onPress={refreshVideos}
        >
          <Text style={[styles.controlButtonText, styles.refreshButtonText]}>Refresh</Text>
        </TouchableOpacity>
        <TouchableOpacity
          style={[styles.controlButton, styles.mapButton]}
          onPress={() => router.push('/map')}
        >
          <Text style={[styles.controlButtonText, styles.mapButtonText]}>View Map</Text>
        </TouchableOpacity>
      </View>

      {hasActiveFilters && (
        <Text style={styles.videoCount}>
          Showing {filteredVideos.length} of {allVideos.length} videos
        </Text>
      )}

      {status === 'error' && (
        <View style={styles.centered}>
          <Text style={styles.errorText}>{errorMessage}</Text>
          <TouchableOpacity style={styles.retryButton} onPress={loadVideos}>
            <Text style={styles.retryButtonText}>Retry</Text>
          </TouchableOpacity>
        </View>
      )}

      {status === 'loaded' && filteredVideos.length === 0 && (
        <View style={styles.centered}>
          <Text style={styles.emptyText}>No videos found.</Text>
          <Text style={styles.emptySubtext}>
            Try pulling to refresh or check your API key configuration.
          </Text>
        </View>
      )}

      <FlatList
        data={filteredVideos}
        keyExtractor={(item) => item.id}
        renderItem={({ item }) => <VideoItem video={item} />}
        contentContainerStyle={styles.list}
        refreshControl={
          <RefreshControl refreshing={isRefreshing} onRefresh={onRefresh} />
        }
      />

      <FilterModal
        visible={filterModalVisible}
        onClose={() => setFilterModalVisible(false)}
        onApply={handleFilterApply}
        channels={channels}
        countries={countries}
        selectedChannel={filters.channelName}
        selectedCountry={filters.country}
      />

      <SortModal
        visible={sortModalVisible}
        onClose={() => setSortModalVisible(false)}
        onApply={sortVideos}
        currentSortBy={sortOptions.sortBy}
        currentSortOrder={sortOptions.sortOrder}
      />
    </SafeAreaView>
  );
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: '#f5f5f5',
    paddingTop: Platform.OS === 'android' ? StatusBar.currentHeight : 0,
  },
  header: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'center',
    paddingHorizontal: 16,
    paddingVertical: 12,
    backgroundColor: '#fff',
    borderBottomWidth: 1,
    borderBottomColor: '#eee',
  },
  headerTitle: {
    fontSize: 20,
    fontWeight: '700',
    color: '#333',
  },
  logoutButton: {
    fontSize: 14,
    color: '#d32f2f',
    fontWeight: '600',
  },
  controls: {
    flexDirection: 'row',
    paddingHorizontal: 12,
    paddingVertical: 8,
    backgroundColor: '#fff',
    borderBottomWidth: 1,
    borderBottomColor: '#eee',
    gap: 8,
    flexWrap: 'wrap',
  },
  controlButton: {
    paddingHorizontal: 12,
    paddingVertical: 8,
    borderRadius: 6,
    backgroundColor: '#f0f0f0',
  },
  controlButtonText: {
    fontSize: 13,
    color: '#333',
    fontWeight: '500',
  },
  refreshButton: {
    backgroundColor: '#e3f2fd',
  },
  refreshButtonText: {
    color: '#1976d2',
  },
  mapButton: {
    backgroundColor: '#e8f5e9',
  },
  mapButtonText: {
    color: '#388e3c',
  },
  videoCount: {
    paddingHorizontal: 16,
    paddingVertical: 8,
    fontSize: 13,
    color: '#666',
    backgroundColor: '#fff',
  },
  centered: {
    flex: 1,
    justifyContent: 'center',
    alignItems: 'center',
    padding: 24,
  },
  loadingText: {
    marginTop: 12,
    fontSize: 16,
    color: '#666',
  },
  errorText: {
    fontSize: 16,
    color: '#d32f2f',
    textAlign: 'center',
    marginBottom: 16,
  },
  retryButton: {
    backgroundColor: '#4285F4',
    paddingHorizontal: 24,
    paddingVertical: 10,
    borderRadius: 6,
  },
  retryButtonText: {
    color: '#fff',
    fontSize: 14,
    fontWeight: '600',
  },
  emptyText: {
    fontSize: 18,
    fontWeight: '600',
    color: '#666',
    marginBottom: 8,
  },
  emptySubtext: {
    fontSize: 14,
    color: '#999',
    textAlign: 'center',
  },
  list: {
    paddingVertical: 8,
  },
});
