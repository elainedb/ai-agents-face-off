import { useEffect, useState } from 'react';
import {
  View,
  Text,
  StyleSheet,
  FlatList,
  TouchableOpacity,
  ActivityIndicator,
  RefreshControl,
  SafeAreaView,
  StatusBar,
  Alert,
  Platform,
} from 'react-native';
import { router } from 'expo-router';
import { useAuthStore } from '@/src/features/authentication/presentation/stores/auth-store';
import { useVideosStore } from '@/src/features/videos/presentation/stores/videos-store';
import { VideoItem } from '@/src/features/videos/presentation/components/VideoItem';
import { FilterModal } from '@/src/features/videos/presentation/components/FilterModal';
import { SortModal } from '@/src/features/videos/presentation/components/SortModal';

export default function MainScreen() {
  const { signOut } = useAuthStore();
  const {
    status,
    filteredVideos,
    allVideos,
    filters,
    sortOptions,
    isRefreshing,
    errorMessage,
    availableChannels,
    availableCountries,
    loadVideos,
    refreshVideos,
    filterByChannel,
    filterByCountry,
    sortVideos,
    clearFilters,
  } = useVideosStore();

  const [showFilter, setShowFilter] = useState(false);
  const [showSort, setShowSort] = useState(false);

  useEffect(() => {
    loadVideos();
  }, []);

  const handleLogout = () => {
    Alert.alert('Logout', 'Are you sure you want to logout?', [
      { text: 'Cancel', style: 'cancel' },
      {
        text: 'Logout',
        style: 'destructive',
        onPress: async () => {
          await signOut();
          router.replace('/login');
        },
      },
    ]);
  };

  const filtersActive = filters.channelName !== null || filters.country !== null;
  const sortLabel = sortOptions.sortBy === 'publishedDate' ? 'Published' : 'Recorded';

  const renderContent = () => {
    if (status === 'loading' && !isRefreshing) {
      return (
        <View style={styles.centered}>
          <ActivityIndicator size="large" color="#4285F4" />
          <Text style={styles.loadingText}>Loading videos...</Text>
        </View>
      );
    }

    if (status === 'error') {
      return (
        <View style={styles.centered}>
          <Text style={styles.errorText}>{errorMessage}</Text>
          <TouchableOpacity style={styles.retryButton} onPress={loadVideos}>
            <Text style={styles.retryButtonText}>Retry</Text>
          </TouchableOpacity>
        </View>
      );
    }

    if (status === 'loaded' && allVideos.length === 0) {
      return (
        <View style={styles.centered}>
          <Text style={styles.emptyText}>No videos found.</Text>
          <Text style={styles.emptyHint}>
            Pull to refresh or check your API key configuration.
          </Text>
        </View>
      );
    }

    return (
      <FlatList
        data={filteredVideos}
        keyExtractor={(item) => item.id}
        renderItem={({ item }) => <VideoItem video={item} />}
        refreshControl={
          <RefreshControl refreshing={isRefreshing} onRefresh={refreshVideos} />
        }
        contentContainerStyle={styles.listContent}
        ListHeaderComponent={
          filtersActive ? (
            <Text style={styles.countText}>
              Showing {filteredVideos.length} of {allVideos.length} videos
            </Text>
          ) : null
        }
      />
    );
  };

  return (
    <SafeAreaView
      style={[
        styles.container,
        { paddingTop: Platform.OS === 'android' ? StatusBar.currentHeight ?? 0 : 0 },
      ]}
    >
      <StatusBar barStyle="dark-content" />

      <View style={styles.header}>
        <Text style={styles.headerTitle}>YouTube Videos</Text>
        <TouchableOpacity onPress={handleLogout}>
          <Text style={styles.logoutText}>Logout</Text>
        </TouchableOpacity>
      </View>

      <View style={styles.controls}>
        <TouchableOpacity style={styles.controlButton} onPress={() => setShowFilter(true)}>
          <Text style={styles.controlButtonText}>
            Filter{filtersActive ? ' (Active)' : ''}
          </Text>
        </TouchableOpacity>
        <TouchableOpacity style={styles.controlButton} onPress={() => setShowSort(true)}>
          <Text style={styles.controlButtonText}>Sort: {sortLabel}</Text>
        </TouchableOpacity>
        <TouchableOpacity
          style={[styles.controlButton, styles.refreshButton]}
          onPress={refreshVideos}
        >
          <Text style={[styles.controlButtonText, { color: '#fff' }]}>Refresh</Text>
        </TouchableOpacity>
        <TouchableOpacity
          style={[styles.controlButton, styles.mapButton]}
          onPress={() => router.push('/map')}
        >
          <Text style={[styles.controlButtonText, { color: '#fff' }]}>View Map</Text>
        </TouchableOpacity>
      </View>

      {renderContent()}

      <FilterModal
        visible={showFilter}
        onClose={() => setShowFilter(false)}
        channels={availableChannels}
        countries={availableCountries}
        selectedChannel={filters.channelName}
        selectedCountry={filters.country}
        onApply={(channel, country) => {
          filterByChannel(channel);
          filterByCountry(country);
        }}
      />

      <SortModal
        visible={showSort}
        onClose={() => setShowSort(false)}
        currentSort={sortOptions}
        onApply={sortVideos}
      />
    </SafeAreaView>
  );
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: '#f5f5f5',
  },
  header: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'center',
    paddingHorizontal: 16,
    paddingVertical: 12,
    backgroundColor: '#fff',
    borderBottomWidth: 1,
    borderBottomColor: '#e0e0e0',
  },
  headerTitle: {
    fontSize: 20,
    fontWeight: '700',
    color: '#212121',
  },
  logoutText: {
    fontSize: 14,
    color: '#d32f2f',
    fontWeight: '600',
  },
  controls: {
    flexDirection: 'row',
    paddingHorizontal: 12,
    paddingVertical: 8,
    gap: 8,
    backgroundColor: '#fff',
    borderBottomWidth: 1,
    borderBottomColor: '#e0e0e0',
  },
  controlButton: {
    paddingVertical: 6,
    paddingHorizontal: 12,
    borderRadius: 6,
    backgroundColor: '#f0f0f0',
  },
  controlButtonText: {
    fontSize: 13,
    color: '#212121',
    fontWeight: '500',
  },
  refreshButton: {
    backgroundColor: '#4285F4',
  },
  mapButton: {
    backgroundColor: '#34a853',
  },
  centered: {
    flex: 1,
    justifyContent: 'center',
    alignItems: 'center',
    padding: 32,
  },
  loadingText: {
    marginTop: 12,
    fontSize: 16,
    color: '#757575',
  },
  errorText: {
    fontSize: 16,
    color: '#d32f2f',
    textAlign: 'center',
    marginBottom: 16,
  },
  retryButton: {
    backgroundColor: '#4285F4',
    paddingVertical: 10,
    paddingHorizontal: 24,
    borderRadius: 6,
  },
  retryButtonText: {
    color: '#fff',
    fontSize: 14,
    fontWeight: '600',
  },
  emptyText: {
    fontSize: 18,
    color: '#212121',
    marginBottom: 8,
  },
  emptyHint: {
    fontSize: 14,
    color: '#757575',
    textAlign: 'center',
  },
  listContent: {
    paddingVertical: 8,
  },
  countText: {
    fontSize: 13,
    color: '#757575',
    paddingHorizontal: 16,
    paddingVertical: 8,
  },
});
