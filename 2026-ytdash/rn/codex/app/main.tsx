import { useRouter } from 'expo-router';
import { useEffect, useMemo, useState } from 'react';
import {
  ActivityIndicator,
  Alert,
  FlatList,
  Pressable,
  RefreshControl,
  StyleSheet,
  Text,
  View,
} from 'react-native';
import { SafeAreaView } from 'react-native-safe-area-context';

import { FilterModal } from '@/src/features/videos/presentation/components/FilterModal';
import { SortModal } from '@/src/features/videos/presentation/components/SortModal';
import { VideoItem } from '@/src/features/videos/presentation/components/VideoItem';
import { useAuthStore } from '@/src/features/authentication/presentation/stores/auth-store';
import { useVideosStore } from '@/src/features/videos/presentation/stores/videos-store';

export default function MainScreen() {
  const router = useRouter();
  const [isFilterOpen, setIsFilterOpen] = useState(false);
  const [isSortOpen, setIsSortOpen] = useState(false);

  const signOut = useAuthStore((state) => state.signOut);
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

  useEffect(() => {
    loadVideos().catch(() => undefined);
  }, [loadVideos]);

  const filterActive = Boolean(filters.channelName || filters.country);
  const sortLabel = sortOptions.sortBy === 'publishedDate' ? 'Published' : 'Recorded';

  const headerCountText = useMemo(() => {
    if (!filterActive) {
      return `Showing ${allVideos.length} videos`;
    }

    return `Showing ${filteredVideos.length} of ${allVideos.length} videos`;
  }, [allVideos.length, filterActive, filteredVideos.length]);

  const renderContent = () => {
    if (status === 'loading' && allVideos.length === 0) {
      return (
        <View style={styles.centerState}>
          <ActivityIndicator color="#4285F4" size="large" />
          <Text style={styles.stateText}>Loading videos...</Text>
        </View>
      );
    }

    if (status === 'error' && allVideos.length === 0) {
      return (
        <View style={styles.centerState}>
          <Text style={styles.errorText}>{errorMessage ?? 'Unable to load videos.'}</Text>
          <Pressable onPress={() => loadVideos().catch(() => undefined)} style={styles.retryButton}>
            <Text style={styles.retryButtonText}>Retry</Text>
          </Pressable>
        </View>
      );
    }

    if (filteredVideos.length === 0) {
      return (
        <View style={styles.centerState}>
          <Text style={styles.stateText}>
            No videos matched the current selection. Pull to refresh or check the API key.
          </Text>
        </View>
      );
    }

    return (
      <FlatList
        data={filteredVideos}
        keyExtractor={(item) => item.id}
        contentContainerStyle={styles.listContent}
        renderItem={({ item }) => <VideoItem video={item} />}
        refreshControl={
          <RefreshControl
            refreshing={isRefreshing}
            onRefresh={() => refreshVideos().catch(() => undefined)}
          />
        }
      />
    );
  };

  return (
    <SafeAreaView style={styles.safeArea}>
      <View style={styles.container}>
        <View style={styles.header}>
          <View>
            <Text style={styles.title}>YouTube Videos</Text>
            <Text style={styles.countText}>{headerCountText}</Text>
          </View>
          <Pressable
            onPress={() =>
              Alert.alert('Logout', 'Sign out from this device?', [
                { text: 'Cancel', style: 'cancel' },
                {
                  text: 'Logout',
                  style: 'destructive',
                  onPress: () => {
                    signOut()
                      .then(() => router.replace('/login'))
                      .catch(() => undefined);
                  },
                },
              ])
            }
            style={styles.logoutButton}>
            <Text style={styles.logoutButtonText}>Logout</Text>
          </Pressable>
        </View>

        <View style={styles.controls}>
          <Pressable onPress={() => setIsFilterOpen(true)} style={styles.controlButton}>
            <Text style={styles.controlButtonText}>
              Filter {filterActive ? '(Active)' : ''}
            </Text>
          </Pressable>
          <Pressable onPress={() => setIsSortOpen(true)} style={styles.controlButton}>
            <Text style={styles.controlButtonText}>Sort ({sortLabel})</Text>
          </Pressable>
          <Pressable onPress={() => refreshVideos().catch(() => undefined)} style={styles.refreshButton}>
            <Text style={styles.primaryButtonText}>Refresh</Text>
          </Pressable>
          <Pressable onPress={() => router.push('/map')} style={styles.mapButton}>
            <Text style={styles.primaryButtonText}>View Map</Text>
          </Pressable>
        </View>

        {renderContent()}
      </View>

      <FilterModal
        visible={isFilterOpen}
        selectedChannel={filters.channelName}
        selectedCountry={filters.country}
        channels={availableChannels}
        countries={availableCountries}
        onClose={() => setIsFilterOpen(false)}
        onApply={({ channelName, country }) => {
          filterByChannel(channelName);
          filterByCountry(country);
        }}
        onClear={clearFilters}
      />

      <SortModal
        visible={isSortOpen}
        selectedSort={sortOptions}
        onClose={() => setIsSortOpen(false)}
        onApply={({ sortBy, sortOrder }) => sortVideos(sortBy, sortOrder)}
      />
    </SafeAreaView>
  );
}

const styles = StyleSheet.create({
  safeArea: {
    flex: 1,
    backgroundColor: '#f4f7fb',
  },
  container: {
    flex: 1,
    paddingHorizontal: 16,
    paddingTop: 10,
  },
  header: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'flex-start',
    marginBottom: 18,
  },
  title: {
    fontSize: 30,
    fontWeight: '800',
    color: '#102030',
  },
  countText: {
    marginTop: 6,
    color: '#51667d',
    fontSize: 14,
  },
  logoutButton: {
    backgroundColor: '#ffebee',
    borderRadius: 14,
    paddingHorizontal: 16,
    paddingVertical: 10,
  },
  logoutButtonText: {
    color: '#c62828',
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
    backgroundColor: '#fff',
    borderWidth: 1,
    borderColor: '#d6e1ed',
    paddingHorizontal: 14,
    paddingVertical: 12,
  },
  controlButtonText: {
    color: '#17324c',
    fontWeight: '700',
  },
  refreshButton: {
    borderRadius: 14,
    backgroundColor: '#4285F4',
    paddingHorizontal: 14,
    paddingVertical: 12,
  },
  mapButton: {
    borderRadius: 14,
    backgroundColor: '#2e7d32',
    paddingHorizontal: 14,
    paddingVertical: 12,
  },
  primaryButtonText: {
    color: '#fff',
    fontWeight: '700',
  },
  listContent: {
    paddingVertical: 8,
    paddingBottom: 24,
  },
  centerState: {
    flex: 1,
    alignItems: 'center',
    justifyContent: 'center',
    paddingHorizontal: 32,
    gap: 14,
  },
  stateText: {
    textAlign: 'center',
    color: '#51667d',
    fontSize: 15,
    lineHeight: 22,
  },
  errorText: {
    textAlign: 'center',
    color: '#d32f2f',
    fontSize: 15,
    lineHeight: 22,
  },
  retryButton: {
    backgroundColor: '#4285F4',
    borderRadius: 14,
    paddingHorizontal: 18,
    paddingVertical: 12,
  },
  retryButtonText: {
    color: '#fff',
    fontWeight: '700',
  },
});
