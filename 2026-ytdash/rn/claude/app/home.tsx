import React, { useEffect, useMemo, useState } from 'react';
import { FlatList, Pressable, StyleSheet, Text, View } from 'react-native';
import { useRouter } from 'expo-router';
import { useAuthStore } from '../src/state/authStore';
import { useVideoStore, computeVisibleVideos } from '../src/state/videoStore';
import { useExternalLinkStore } from '../src/state/externalLinkStore';
import { distinctCategories } from '../src/domain/filterSort';
import { Video } from '../src/domain/types';
import { LoadingView } from '../src/components/LoadingView';
import { ErrorView } from '../src/components/ErrorView';
import { EmptyView } from '../src/components/EmptyView';
import { VideoListItem } from '../src/components/VideoListItem';
import { FilterPanel } from '../src/components/FilterPanel';
import { SortPanel } from '../src/components/SortPanel';

type Panel = 'list' | 'filter' | 'sort';

export default function Home() {
  const router = useRouter();
  const signOut = useAuthStore((s) => s.signOut);
  const openLink = useExternalLinkStore((s) => s.open);

  const status = useVideoStore((s) => s.status);
  const videos = useVideoStore((s) => s.videos);
  const errorMessage = useVideoStore((s) => s.errorMessage);
  const filterCategory = useVideoStore((s) => s.filterCategory);
  const sortKey = useVideoStore((s) => s.sortKey);
  const sortDirection = useVideoStore((s) => s.sortDirection);
  const load = useVideoStore((s) => s.load);
  const refresh = useVideoStore((s) => s.refresh);
  const setFilter = useVideoStore((s) => s.setFilter);
  const setSort = useVideoStore((s) => s.setSort);
  const visibleVideos = useMemo(
    () => computeVisibleVideos(videos, filterCategory, sortKey, sortDirection),
    [videos, filterCategory, sortKey, sortDirection],
  );

  const [panel, setPanel] = useState<Panel>('list');

  useEffect(() => {
    load();
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, []);

  const handleLogout = () => {
    signOut();
    router.replace('/login');
  };

  const handleOpenVideo = (video: Video) => {
    openLink(video.youtubeUrl);
  };

  const categories = distinctCategories(videos);

  return (
    <View testID="screen_home" style={styles.container}>
      <View style={styles.header}>
        <View style={styles.headerLeft}>
          <Text style={styles.headerTitle}>ytdash</Text>
          <Text testID="video_count" style={styles.headerCount}>
            {videos.length} videos loaded
          </Text>
        </View>
        <View style={styles.headerActions}>
          <Pressable testID="refresh_control" style={styles.iconButton} onPress={refresh}>
            <Text style={styles.iconButtonText}>Refresh</Text>
          </Pressable>
          <Pressable testID="filter_button" style={styles.iconButton} onPress={() => setPanel('filter')}>
            <Text style={styles.iconButtonText}>Filter</Text>
          </Pressable>
          <Pressable testID="sort_button" style={styles.iconButton} onPress={() => setPanel('sort')}>
            <Text style={styles.iconButtonText}>Sort</Text>
          </Pressable>
          <Pressable testID="map_nav_button" style={styles.iconButton} onPress={() => router.push('/map')}>
            <Text style={styles.iconButtonText}>Map</Text>
          </Pressable>
          <Pressable testID="logout_button" style={styles.iconButton} onPress={handleLogout}>
            <Text style={styles.iconButtonText}>Logout</Text>
          </Pressable>
        </View>
      </View>

      {panel === 'filter' ? (
        <FilterPanel
          categories={categories}
          selected={filterCategory}
          onSelect={(category) => {
            setFilter(category);
            setPanel('list');
          }}
        />
      ) : panel === 'sort' ? (
        <SortPanel
          sortKey={sortKey}
          sortDirection={sortDirection}
          onSelect={(key, direction) => {
            setSort(key, direction);
            setPanel('list');
          }}
        />
      ) : status === 'loading' ? (
        <LoadingView />
      ) : status === 'error' ? (
        <ErrorView message={errorMessage ?? 'Something went wrong.'} onRetry={load} />
      ) : status === 'empty' ? (
        <EmptyView />
      ) : (
        <FlatList
          testID="video_list"
          data={visibleVideos}
          keyExtractor={(item) => item.id}
          renderItem={({ item }) => <VideoListItem video={item} onPress={handleOpenVideo} />}
        />
      )}
    </View>
  );
}

const styles = StyleSheet.create({
  container: { flex: 1, backgroundColor: 'white' },
  header: {
    paddingTop: 48,
    paddingHorizontal: 16,
    paddingBottom: 12,
    borderBottomWidth: StyleSheet.hairlineWidth,
    borderBottomColor: '#e5e7eb',
    gap: 8,
  },
  headerLeft: {},
  headerTitle: { fontSize: 20, fontWeight: '700' },
  headerCount: { fontSize: 13, color: '#6b7280' },
  headerActions: { flexDirection: 'row', flexWrap: 'wrap', gap: 8 },
  iconButton: {
    backgroundColor: '#f3f4f6',
    paddingHorizontal: 12,
    paddingVertical: 8,
    borderRadius: 8,
  },
  iconButtonText: { fontSize: 13, fontWeight: '600', color: '#1f2937' },
});
