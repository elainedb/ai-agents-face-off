import { ReactNode, useMemo, useState } from 'react';
import { FlatList, Pressable, StyleSheet, Text, View } from 'react-native';

import { filterVideosByCategory } from '../../domain/filter';
import { sortVideos } from '../../domain/sort';
import { Video } from '../../domain/types';
import { useAuthStore } from '../../state/authStore';
import { useExternalLinkStore } from '../../state/externalLinkStore';
import { useNavStore } from '../../state/navStore';
import { useVideoStore } from '../../state/videoStore';
import { ErrorView } from '../components/ErrorView';
import { FilterPanel } from '../components/FilterPanel';
import { LoadingView } from '../components/LoadingView';
import { SortPanel } from '../components/SortPanel';
import { VideoListItem } from '../components/VideoListItem';

type Panel = 'none' | 'filter' | 'sort';

export function HomeScreen() {
  const [panel, setPanel] = useState<Panel>('none');

  const status = useVideoStore((s) => s.status);
  const videos = useVideoStore((s) => s.videos);
  const filter = useVideoStore((s) => s.filter);
  const sortDirection = useVideoStore((s) => s.sortDirection);
  const errorMessage = useVideoStore((s) => s.errorMessage);
  const refresh = useVideoStore((s) => s.refresh);
  const setFilter = useVideoStore((s) => s.setFilter);
  const setSortDirection = useVideoStore((s) => s.setSortDirection);

  const signOut = useAuthStore((s) => s.signOut);
  const goMap = useNavStore((s) => s.goMap);
  const openExternal = useExternalLinkStore((s) => s.open);

  const visibleVideos = useMemo(() => {
    const filtered = filterVideosByCategory(videos, filter);
    return sortDirection ? sortVideos(filtered, 'date', sortDirection) : filtered;
  }, [videos, filter, sortDirection]);

  function handleOpenVideo(video: Video) {
    openExternal(video.youtubeUrl);
  }

  let body: ReactNode;
  if (panel === 'filter') {
    body = (
      <FilterPanel
        current={filter}
        onCancel={() => setPanel('none')}
        onApply={(category) => {
          setFilter(category);
          setPanel('none');
        }}
      />
    );
  } else if (panel === 'sort') {
    body = (
      <SortPanel
        current={sortDirection}
        onCancel={() => setPanel('none')}
        onApply={(direction) => {
          setSortDirection(direction);
          setPanel('none');
        }}
      />
    );
  } else if (status === 'loading') {
    body = <LoadingView label="Loading videos…" />;
  } else if (status === 'error') {
    body = <ErrorView message={errorMessage ?? 'Something went wrong.'} onRetry={refresh} />;
  } else {
    body = (
      <FlatList
        testID="video_list"
        data={visibleVideos}
        keyExtractor={(item) => item.id}
        renderItem={({ item }) => <VideoListItem video={item} onPress={handleOpenVideo} />}
        ListEmptyComponent={<Text style={styles.empty}>No videos match the current filter.</Text>}
      />
    );
  }

  return (
    <View testID="screen_home" style={styles.container}>
      <View style={styles.header}>
        <Text testID="video_count" style={styles.title}>
          ytdash · {videos.length} videos
        </Text>
        <View style={styles.actions}>
          <Pressable testID="refresh_control" onPress={refresh} style={styles.iconButton}>
            <Text style={styles.iconText}>Refresh</Text>
          </Pressable>
          <Pressable testID="filter_button" onPress={() => setPanel('filter')} style={styles.iconButton}>
            <Text style={styles.iconText}>Filter</Text>
          </Pressable>
          <Pressable testID="sort_button" onPress={() => setPanel('sort')} style={styles.iconButton}>
            <Text style={styles.iconText}>Sort</Text>
          </Pressable>
          <Pressable testID="map_nav_button" onPress={goMap} style={styles.iconButton}>
            <Text style={styles.iconText}>Map</Text>
          </Pressable>
          <Pressable testID="logout_button" onPress={signOut} style={styles.iconButton}>
            <Text style={styles.iconText}>Logout</Text>
          </Pressable>
        </View>
      </View>
      {body}
    </View>
  );
}

const styles = StyleSheet.create({
  container: { flex: 1, backgroundColor: '#fff' },
  header: { paddingTop: 48, paddingHorizontal: 16, paddingBottom: 8, gap: 8, borderBottomWidth: StyleSheet.hairlineWidth, borderBottomColor: '#ddd' },
  title: { fontSize: 18, fontWeight: '700' },
  actions: { flexDirection: 'row', flexWrap: 'wrap', gap: 8 },
  iconButton: { paddingVertical: 6, paddingHorizontal: 12, backgroundColor: '#f2f2f2', borderRadius: 6 },
  iconText: { fontSize: 13, fontWeight: '600', color: '#1a73e8' },
  empty: { textAlign: 'center', marginTop: 32, color: '#888' },
});
