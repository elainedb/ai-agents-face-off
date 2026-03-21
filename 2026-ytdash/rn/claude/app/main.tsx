import React, { useEffect, useState } from 'react';
import {
  View,
  Text,
  FlatList,
  TouchableOpacity,
  StyleSheet,
  ActivityIndicator,
  Alert,
  Platform,
  StatusBar,
  RefreshControl,
  SafeAreaView,
} from 'react-native';
import { useRouter } from 'expo-router';
import { GoogleSignin } from '@react-native-google-signin/google-signin';
import { fetchAllVideos } from '@/services/cacheService';
import type { VideoData } from '@/services/youtubeApi';
import VideoItem from '@/components/VideoItem';
import FilterModal, { type FilterOptions } from '@/components/FilterModal';
import SortModal, { type SortOptions } from '@/components/SortModal';

export default function MainScreen() {
  const router = useRouter();
  const [allVideos, setAllVideos] = useState<VideoData[]>([]);
  const [filteredVideos, setFilteredVideos] = useState<VideoData[]>([]);
  const [loading, setLoading] = useState(true);
  const [refreshing, setRefreshing] = useState(false);
  const [filters, setFilters] = useState<FilterOptions>({
    channel: null,
    country: null,
  });
  const [sortOptions, setSortOptions] = useState<SortOptions>({
    field: 'publishedAt',
    order: 'newest',
  });
  const [showFilterModal, setShowFilterModal] = useState(false);
  const [showSortModal, setShowSortModal] = useState(false);

  useEffect(() => {
    loadVideos();
  }, []);

  useEffect(() => {
    let videos = [...allVideos];

    // Apply filters
    if (filters.channel) {
      videos = videos.filter((v) => v.channelName === filters.channel);
    }
    if (filters.country) {
      videos = videos.filter((v) => v.location?.country === filters.country);
    }

    // Apply sort
    videos.sort((a, b) => {
      let dateA: string;
      let dateB: string;

      if (sortOptions.field === 'recordingDate') {
        dateA = a.recordingDate || a.publishedAt;
        dateB = b.recordingDate || b.publishedAt;
      } else {
        dateA = a.publishedAt;
        dateB = b.publishedAt;
      }

      const diff = new Date(dateB).getTime() - new Date(dateA).getTime();
      return sortOptions.order === 'newest' ? diff : -diff;
    });

    setFilteredVideos(videos);
  }, [allVideos, filters, sortOptions]);

  const loadVideos = async (forceRefresh = false) => {
    try {
      const videos = await fetchAllVideos(forceRefresh);
      setAllVideos(videos);
    } catch (err) {
      console.error('Error loading videos:', err);
    } finally {
      setLoading(false);
      setRefreshing(false);
    }
  };

  const handleRefresh = () => {
    setRefreshing(true);
    loadVideos(true);
  };

  const handleLogout = () => {
    Alert.alert('Logout', 'Are you sure you want to sign out?', [
      { text: 'Cancel', style: 'cancel' },
      {
        text: 'Sign Out',
        style: 'destructive',
        onPress: async () => {
          try {
            await GoogleSignin.signOut();
          } catch {}
          router.replace('/login');
        },
      },
    ]);
  };

  const channels = [...new Set(allVideos.map((v) => v.channelName))].sort();
  const countries = [
    ...new Set(
      allVideos
        .map((v) => v.location?.country)
        .filter(Boolean) as string[]
    ),
  ].sort();

  const filtersActive = filters.channel !== null || filters.country !== null;
  const sortLabel =
    sortOptions.field === 'publishedAt' ? 'Published' : 'Recorded';

  if (loading) {
    return (
      <SafeAreaView style={styles.loadingContainer}>
        <ActivityIndicator size="large" color="#4285F4" />
        <Text style={styles.loadingText}>Loading videos...</Text>
      </SafeAreaView>
    );
  }

  return (
    <SafeAreaView
      style={[
        styles.container,
        { paddingTop: Platform.OS === 'android' ? StatusBar.currentHeight : 0 },
      ]}
    >
      <StatusBar barStyle="dark-content" backgroundColor="#fff" />

      {/* Header */}
      <View style={styles.header}>
        <Text style={styles.headerTitle}>YouTube Videos</Text>
        <TouchableOpacity onPress={handleLogout}>
          <Text style={styles.logoutText}>Logout</Text>
        </TouchableOpacity>
      </View>

      {/* Controls */}
      <View style={styles.controls}>
        <TouchableOpacity
          style={styles.controlButton}
          onPress={() => setShowFilterModal(true)}
        >
          <Text style={styles.controlButtonText}>
            Filter{filtersActive ? ' (Active)' : ''}
          </Text>
        </TouchableOpacity>

        <TouchableOpacity
          style={styles.controlButton}
          onPress={() => setShowSortModal(true)}
        >
          <Text style={styles.controlButtonText}>Sort: {sortLabel}</Text>
        </TouchableOpacity>

        <TouchableOpacity
          style={[styles.controlButton, styles.refreshButton]}
          onPress={handleRefresh}
        >
          <Text style={[styles.controlButtonText, styles.refreshButtonText]}>
            Refresh
          </Text>
        </TouchableOpacity>

        <TouchableOpacity
          style={[styles.controlButton, styles.mapButton]}
          onPress={() => router.push('/map')}
        >
          <Text style={[styles.controlButtonText, styles.mapButtonText]}>
            View Map
          </Text>
        </TouchableOpacity>
      </View>

      {/* Stats */}
      <Text style={styles.stats}>
        Showing {filteredVideos.length} of {allVideos.length} videos
      </Text>

      {/* Video List */}
      {filteredVideos.length === 0 ? (
        <View style={styles.emptyContainer}>
          <Text style={styles.emptyText}>
            No videos found. Pull to refresh or check your API key.
          </Text>
        </View>
      ) : (
        <FlatList
          data={filteredVideos}
          keyExtractor={(item) => item.id}
          renderItem={({ item }) => <VideoItem video={item} />}
          refreshControl={
            <RefreshControl refreshing={refreshing} onRefresh={handleRefresh} />
          }
        />
      )}

      {/* Modals */}
      <FilterModal
        visible={showFilterModal}
        onClose={() => setShowFilterModal(false)}
        onApply={setFilters}
        channels={channels}
        countries={countries}
        currentFilters={filters}
      />
      <SortModal
        visible={showSortModal}
        onClose={() => setShowSortModal(false)}
        onApply={setSortOptions}
        currentSort={sortOptions}
      />
    </SafeAreaView>
  );
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: '#fff',
  },
  loadingContainer: {
    flex: 1,
    justifyContent: 'center',
    alignItems: 'center',
    backgroundColor: '#fff',
  },
  loadingText: {
    marginTop: 12,
    fontSize: 16,
    color: '#666',
  },
  header: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'center',
    paddingHorizontal: 16,
    paddingVertical: 12,
    borderBottomWidth: 1,
    borderBottomColor: '#eee',
  },
  headerTitle: {
    fontSize: 20,
    fontWeight: 'bold',
    color: '#333',
  },
  logoutText: {
    color: '#d32f2f',
    fontSize: 14,
    fontWeight: '600',
  },
  controls: {
    flexDirection: 'row',
    paddingHorizontal: 12,
    paddingVertical: 8,
    gap: 6,
    flexWrap: 'wrap',
  },
  controlButton: {
    paddingHorizontal: 12,
    paddingVertical: 8,
    borderRadius: 6,
    backgroundColor: '#f0f0f0',
  },
  controlButtonText: {
    fontSize: 12,
    color: '#333',
    fontWeight: '500',
  },
  refreshButton: {
    backgroundColor: '#4285F4',
  },
  refreshButtonText: {
    color: '#fff',
  },
  mapButton: {
    backgroundColor: '#34A853',
  },
  mapButtonText: {
    color: '#fff',
  },
  stats: {
    paddingHorizontal: 16,
    paddingVertical: 6,
    fontSize: 12,
    color: '#888',
  },
  emptyContainer: {
    flex: 1,
    justifyContent: 'center',
    alignItems: 'center',
    padding: 40,
  },
  emptyText: {
    textAlign: 'center',
    color: '#888',
    fontSize: 14,
  },
});
