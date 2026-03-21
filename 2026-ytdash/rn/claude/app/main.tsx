import React, { useEffect, useState, useCallback } from 'react';
import {
  View,
  Text,
  FlatList,
  TouchableOpacity,
  StyleSheet,
  ActivityIndicator,
  Alert,
  SafeAreaView,
  StatusBar,
  Platform,
  RefreshControl,
} from 'react-native';
import { useRouter } from 'expo-router';
import { fetchAllVideos, type VideoData } from '@/services/youtubeApi';

let GoogleSignin: any = null;
try {
  GoogleSignin = require('@react-native-google-signin/google-signin').GoogleSignin;
} catch (e) {
  console.warn('Google Sign-In native module not available:', e);
}
import VideoItem from '@/components/VideoItem';
import FilterModal, { type Filters } from '@/components/FilterModal';
import SortModal, { type SortOptions } from '@/components/SortModal';

export default function MainScreen() {
  const router = useRouter();
  const [allVideos, setAllVideos] = useState<VideoData[]>([]);
  const [displayedVideos, setDisplayedVideos] = useState<VideoData[]>([]);
  const [loading, setLoading] = useState(true);
  const [refreshing, setRefreshing] = useState(false);
  const [filterModalVisible, setFilterModalVisible] = useState(false);
  const [sortModalVisible, setSortModalVisible] = useState(false);
  const [filters, setFilters] = useState<Filters>({ channel: null, country: null });
  const [sortOptions, setSortOptions] = useState<SortOptions>({
    field: 'publishedAt',
    order: 'desc',
  });

  const loadVideos = useCallback(async (forceRefresh = false) => {
    try {
      const videos = await fetchAllVideos(forceRefresh);
      setAllVideos(videos);
    } catch (error) {
      console.error('Error loading videos:', error);
    } finally {
      setLoading(false);
      setRefreshing(false);
    }
  }, []);

  useEffect(() => {
    loadVideos();
  }, [loadVideos]);

  // Filter and sort
  useEffect(() => {
    let filtered = [...allVideos];

    if (filters.channel) {
      filtered = filtered.filter(v => v.channelName === filters.channel);
    }
    if (filters.country) {
      filtered = filtered.filter(v => v.location?.country === filters.country);
    }

    filtered.sort((a, b) => {
      let dateA: string;
      let dateB: string;

      if (sortOptions.field === 'recordingDate') {
        dateA = a.recordingDate || a.publishedAt;
        dateB = b.recordingDate || b.publishedAt;
      } else {
        dateA = a.publishedAt;
        dateB = b.publishedAt;
      }

      const comparison = new Date(dateA).getTime() - new Date(dateB).getTime();
      return sortOptions.order === 'desc' ? -comparison : comparison;
    });

    setDisplayedVideos(filtered);
  }, [allVideos, filters, sortOptions]);

  const handleRefresh = () => {
    setRefreshing(true);
    loadVideos(true);
  };

  const handleLogout = () => {
    Alert.alert('Logout', 'Are you sure you want to log out?', [
      { text: 'Cancel', style: 'cancel' },
      {
        text: 'Logout',
        style: 'destructive',
        onPress: async () => {
          try {
            if (GoogleSignin) await GoogleSignin.signOut();
          } catch (e) {
            console.warn('Sign out error:', e);
          }
          router.replace('/login');
        },
      },
    ]);
  };

  const channels = [...new Set(allVideos.map(v => v.channelName))].sort();
  const countries = [
    ...new Set(
      allVideos
        .map(v => v.location?.country)
        .filter(Boolean) as string[]
    ),
  ].sort();

  const filtersActive = filters.channel !== null || filters.country !== null;
  const sortLabel = sortOptions.field === 'publishedAt' ? 'Published' : 'Recorded';

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
      <StatusBar barStyle="dark-content" />

      {/* Header */}
      <View style={styles.header}>
        <Text style={styles.headerTitle}>YouTube Videos</Text>
        <TouchableOpacity style={styles.logoutButton} onPress={handleLogout}>
          <Text style={styles.logoutText}>Logout</Text>
        </TouchableOpacity>
      </View>

      {/* Controls */}
      <View style={styles.controls}>
        <TouchableOpacity
          style={styles.controlButton}
          onPress={() => setFilterModalVisible(true)}
        >
          <Text style={styles.controlText}>
            Filter{filtersActive ? ' (Active)' : ''}
          </Text>
        </TouchableOpacity>

        <TouchableOpacity
          style={styles.controlButton}
          onPress={() => setSortModalVisible(true)}
        >
          <Text style={styles.controlText}>Sort: {sortLabel}</Text>
        </TouchableOpacity>

        <TouchableOpacity
          style={[styles.controlButton, styles.refreshButton]}
          onPress={handleRefresh}
        >
          <Text style={[styles.controlText, styles.refreshText]}>Refresh</Text>
        </TouchableOpacity>

        <TouchableOpacity
          style={[styles.controlButton, styles.mapButton]}
          onPress={() => router.push('/map')}
        >
          <Text style={[styles.controlText, styles.mapText]}>View Map</Text>
        </TouchableOpacity>
      </View>

      {/* Stats */}
      <Text style={styles.stats}>
        Showing {displayedVideos.length} of {allVideos.length} videos
      </Text>

      {/* Video List */}
      {allVideos.length === 0 ? (
        <View style={styles.emptyContainer}>
          <Text style={styles.emptyText}>No videos found.</Text>
          <Text style={styles.emptySubtext}>
            Pull to refresh or check your API key.
          </Text>
        </View>
      ) : (
        <FlatList
          data={displayedVideos}
          keyExtractor={item => item.id}
          renderItem={({ item }) => <VideoItem video={item} />}
          refreshControl={
            <RefreshControl refreshing={refreshing} onRefresh={handleRefresh} />
          }
          contentContainerStyle={styles.listContent}
        />
      )}

      <FilterModal
        visible={filterModalVisible}
        onClose={() => setFilterModalVisible(false)}
        onApply={setFilters}
        filters={filters}
        channels={channels}
        countries={countries}
      />

      <SortModal
        visible={sortModalVisible}
        onClose={() => setSortModalVisible(false)}
        onApply={setSortOptions}
        sortOptions={sortOptions}
      />
    </SafeAreaView>
  );
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: '#f5f5f5',
  },
  loadingContainer: {
    flex: 1,
    justifyContent: 'center',
    alignItems: 'center',
    backgroundColor: '#f5f5f5',
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
    backgroundColor: '#fff',
    borderBottomWidth: 1,
    borderBottomColor: '#eee',
  },
  headerTitle: {
    fontSize: 20,
    fontWeight: 'bold',
  },
  logoutButton: {
    backgroundColor: '#d32f2f',
    paddingHorizontal: 16,
    paddingVertical: 8,
    borderRadius: 6,
  },
  logoutText: {
    color: '#fff',
    fontWeight: '600',
  },
  controls: {
    flexDirection: 'row',
    padding: 12,
    gap: 8,
    backgroundColor: '#fff',
    borderBottomWidth: 1,
    borderBottomColor: '#eee',
  },
  controlButton: {
    paddingHorizontal: 12,
    paddingVertical: 8,
    borderRadius: 6,
    backgroundColor: '#f0f0f0',
  },
  controlText: {
    fontSize: 13,
    color: '#333',
    fontWeight: '500',
  },
  refreshButton: {
    backgroundColor: '#e3f2fd',
  },
  refreshText: {
    color: '#1976d2',
  },
  mapButton: {
    backgroundColor: '#e8f5e9',
  },
  mapText: {
    color: '#388e3c',
  },
  stats: {
    paddingHorizontal: 16,
    paddingVertical: 8,
    fontSize: 13,
    color: '#888',
  },
  listContent: {
    paddingBottom: 20,
  },
  emptyContainer: {
    flex: 1,
    justifyContent: 'center',
    alignItems: 'center',
    padding: 40,
  },
  emptyText: {
    fontSize: 18,
    fontWeight: '600',
    color: '#333',
  },
  emptySubtext: {
    fontSize: 14,
    color: '#888',
    marginTop: 8,
    textAlign: 'center',
  },
});
