import React, { useEffect, useState } from 'react';
import { ActivityIndicator, FlatList, Platform, Pressable, StatusBar, StyleSheet, Text, View } from 'react-native';

import { distinctCategories } from '../../domain/sortFilter';
import { useExternalLinkStore } from '../../state/externalLinkStore';
import { useVideoStore } from '../../state/videoStore';
import { FilterPanel } from '../components/FilterPanel';
import { SortPanel } from '../components/SortPanel';
import { VideoListItem } from '../components/VideoListItem';

type Mode = 'list' | 'filter' | 'sort';

type Props = {
  onNavigateMap: () => void;
  onLogout: () => void;
};

export function HomeScreen({ onNavigateMap, onLogout }: Props) {
  const [mode, setMode] = useState<Mode>('list');
  const allVideos = useVideoStore((s) => s.allVideos);
  const viewState = useVideoStore((s) => s.viewState);
  const filterLabel = useVideoStore((s) => s.filterLabel);
  const sortKey = useVideoStore((s) => s.sortKey);
  const visibleVideos = useVideoStore((s) => s.visibleVideos)();
  const load = useVideoStore((s) => s.load);
  const refresh = useVideoStore((s) => s.refresh);
  const setFilter = useVideoStore((s) => s.setFilter);
  const setSort = useVideoStore((s) => s.setSort);
  const open = useExternalLinkStore((s) => s.open);

  useEffect(() => {
    load();
  }, []);

  if (mode === 'filter') {
    return (
      <View testID="screen_home" style={styles.container}>
        <FilterPanel
          categories={distinctCategories(allVideos)}
          currentFilter={filterLabel}
          onApply={(label) => {
            setFilter(label);
            setMode('list');
          }}
          onClose={() => setMode('list')}
        />
      </View>
    );
  }

  if (mode === 'sort') {
    return (
      <View testID="screen_home" style={styles.container}>
        <SortPanel
          currentSort={sortKey}
          onApply={(key) => {
            setSort(key);
            setMode('list');
          }}
          onClose={() => setMode('list')}
        />
      </View>
    );
  }

  return (
    <View testID="screen_home" style={styles.container}>
      <View style={styles.header}>
        <View style={styles.headerRow}>
          <Text testID="video_count" style={styles.title}>
            Videos ({allVideos.length})
          </Text>
          <Pressable testID="logout_button" style={styles.headerButton} onPress={onLogout}>
            <Text style={styles.headerButtonText}>Logout</Text>
          </Pressable>
        </View>
        <View style={styles.headerRow}>
          <Pressable testID="refresh_control" style={styles.smallButton} onPress={() => refresh()}>
            <Text style={styles.smallButtonText}>Refresh</Text>
          </Pressable>
          <Pressable testID="filter_button" style={styles.smallButton} onPress={() => setMode('filter')}>
            <Text style={styles.smallButtonText}>Filter</Text>
          </Pressable>
          <Pressable testID="sort_button" style={styles.smallButton} onPress={() => setMode('sort')}>
            <Text style={styles.smallButtonText}>Sort</Text>
          </Pressable>
          <Pressable testID="map_nav_button" style={styles.smallButton} onPress={onNavigateMap}>
            <Text style={styles.smallButtonText}>Map</Text>
          </Pressable>
        </View>
      </View>

      <View style={styles.listArea}>
        <FlatList
          testID="video_list"
          data={visibleVideos}
          keyExtractor={(item) => item.id}
          renderItem={({ item }) => <VideoListItem video={item} onPress={(v) => open(v.youtubeUrl)} />}
          ListEmptyComponent={
            viewState === 'empty' ? (
              <View style={styles.center}>
                <Text>No videos found.</Text>
              </View>
            ) : null
          }
        />
        {viewState === 'loading' && allVideos.length === 0 ? (
          <View style={[styles.center, styles.overlay]} testID="loading_indicator">
            <ActivityIndicator size="large" />
          </View>
        ) : null}
        {viewState === 'error' && allVideos.length === 0 ? (
          <View style={[styles.center, styles.overlay]} testID="error_view">
            <Text style={styles.errorText}>Something went wrong loading videos.</Text>
            <Pressable testID="error_retry_button" style={styles.retryButton} onPress={() => load()}>
              <Text style={styles.retryButtonText}>Retry</Text>
            </Pressable>
          </View>
        ) : null}
      </View>
    </View>
  );
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: '#fff',
  },
  header: {
    padding: 12,
    paddingTop: (Platform.OS === 'android' ? StatusBar.currentHeight ?? 24 : 0) + 12,
    borderBottomWidth: StyleSheet.hairlineWidth,
    borderBottomColor: '#ddd',
  },
  headerRow: {
    flexDirection: 'row',
    alignItems: 'center',
    justifyContent: 'space-between',
    marginBottom: 8,
  },
  title: {
    fontSize: 20,
    fontWeight: '700',
  },
  headerButton: {
    paddingVertical: 6,
    paddingHorizontal: 12,
  },
  headerButtonText: {
    color: '#a00',
  },
  smallButton: {
    paddingVertical: 6,
    paddingHorizontal: 10,
    backgroundColor: '#f0f0f0',
    borderRadius: 4,
  },
  smallButtonText: {
    fontSize: 13,
  },
  listArea: {
    flex: 1,
  },
  overlay: {
    position: 'absolute',
    top: 0,
    left: 0,
    right: 0,
    bottom: 0,
    backgroundColor: '#fff',
  },
  center: {
    flex: 1,
    alignItems: 'center',
    justifyContent: 'center',
    padding: 24,
  },
  errorText: {
    color: '#a00',
    marginBottom: 12,
    textAlign: 'center',
  },
  retryButton: {
    backgroundColor: '#1a73e8',
    paddingVertical: 10,
    paddingHorizontal: 20,
    borderRadius: 6,
  },
  retryButtonText: {
    color: 'white',
  },
});
