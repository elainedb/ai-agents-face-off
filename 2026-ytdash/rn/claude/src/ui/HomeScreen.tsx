import React, { useMemo, useState } from 'react';
import {
  View,
  Text,
  Pressable,
  StyleSheet,
  FlatList,
  Image,
  Modal,
  ActivityIndicator,
  RefreshControl,
} from 'react-native';
import { IDS } from './selectors';
import { useVideosStore, useUiStore, useAuthStore, useExternalStore } from '../state/stores';
import { availableCategories, filterVideos } from '../domain/filter';
import { sortVideos, SORT_OPTIONS, SortOption } from '../domain/sort';
import { Video } from '../data/types';

function HeaderButton({ id, label, onPress }: { id: string; label: string; onPress: () => void }) {
  return (
    <Pressable testID={id} accessibilityLabel={id} style={styles.headerBtn} onPress={onPress}>
      <Text style={styles.headerBtnText}>{label}</Text>
    </Pressable>
  );
}

function VideoRow({ item, onPress }: { item: Video; onPress: (v: Video) => void }) {
  return (
    <Pressable
      testID={IDS.videoListItem}
      // Label the row node with the title so the SAME node that carries the id also carries the
      // text — AC-SORT-01 asserts id:video_list_item index:0 AND text on one node (§D.4). RN/Fabric
      // does not aggregate descendant text onto the testID node, so we set it explicitly.
      accessibilityLabel={item.title}
      style={styles.row}
      onPress={() => onPress(item)}
    >
      {item.thumbnailUrl ? (
        <Image source={{ uri: item.thumbnailUrl }} style={styles.thumb} />
      ) : (
        <View style={[styles.thumb, styles.thumbPlaceholder]} />
      )}
      <View style={styles.rowText}>
        <Text style={styles.rowTitle} numberOfLines={2}>
          {item.title}
        </Text>
        <Text style={styles.rowMeta} numberOfLines={1}>
          {item.category} · {item.publishedAt?.slice(0, 10)}
        </Text>
        <Text style={styles.rowDesc} numberOfLines={1}>
          {item.description}
        </Text>
      </View>
    </Pressable>
  );
}

export default function HomeScreen() {
  const status = useVideosStore((s) => s.status);
  const all = useVideosStore((s) => s.all);
  const error = useVideosStore((s) => s.error);
  const refresh = useVideosStore((s) => s.refresh);
  const load = useVideosStore((s) => s.load);

  const filter = useUiStore((s) => s.filter);
  const sort = useUiStore((s) => s.sort);
  const setFilter = useUiStore((s) => s.setFilter);
  const setSort = useUiStore((s) => s.setSort);
  const setScreen = useUiStore((s) => s.setScreen);

  const signOut = useAuthStore((s) => s.signOut);
  const openExternal = useExternalStore((s) => s.open);
  const resetVideos = useVideosStore((s) => s.reset);

  const [filterOpen, setFilterOpen] = useState(false);
  const [sortOpen, setSortOpen] = useState(false);
  const [pendingFilter, setPendingFilter] = useState<string | null>(filter);
  const [pendingSort, setPendingSort] = useState<SortOption | null>(sort);
  const [refreshing, setRefreshing] = useState(false);

  const categories = useMemo(() => availableCategories(all), [all]);

  const visible = useMemo(() => {
    const filtered = filterVideos(all, filter);
    return sort ? sortVideos(filtered, sort) : filtered;
  }, [all, filter, sort]);

  const onRefresh = async () => {
    setRefreshing(true);
    try {
      await refresh();
    } finally {
      setRefreshing(false);
    }
  };

  const onLogout = () => {
    signOut();
    resetVideos();
    setFilter(null);
    setSort(null);
    setScreen('login');
  };

  const applyFilter = () => {
    setFilter(pendingFilter);
    setFilterOpen(false);
  };
  const applySort = () => {
    setSort(pendingSort);
    setSortOpen(false);
  };

  return (
    <View style={styles.container} testID={IDS.screenHome} accessibilityLabel={IDS.screenHome}>
      {/* Title with the TOTAL loaded count (constitution §3: video_count). */}
      <View style={styles.titleRow}>
        <Text
          testID={IDS.videoCount}
          accessibilityLabel={IDS.videoCount}
          style={styles.title}
        >
          {all.length} videos
        </Text>
      </View>

      <View style={styles.toolbar}>
        <HeaderButton id={IDS.refreshControl} label="Refresh" onPress={onRefresh} />
        <HeaderButton
          id={IDS.filterButton}
          label="Filter"
          onPress={() => {
            setPendingFilter(filter);
            setFilterOpen(true);
          }}
        />
        <HeaderButton
          id={IDS.sortButton}
          label="Sort"
          onPress={() => {
            setPendingSort(sort);
            setSortOpen(true);
          }}
        />
        <HeaderButton id={IDS.mapNavButton} label="Map" onPress={() => setScreen('map')} />
        <HeaderButton id={IDS.logoutButton} label="Logout" onPress={onLogout} />
      </View>

      {status === 'loading' ? (
        <View style={styles.center}>
          <ActivityIndicator
            testID={IDS.loadingIndicator}
            accessibilityLabel={IDS.loadingIndicator}
            size="large"
            color="#c4302b"
          />
          <Text style={styles.dim}>Loading videos…</Text>
        </View>
      ) : status === 'error' ? (
        <View style={styles.center} testID={IDS.errorView} accessibilityLabel={IDS.errorView}>
          <Text style={styles.errorText}>Could not load videos.</Text>
          <Text style={styles.dim}>{error?.message}</Text>
          <Pressable
            testID={IDS.errorRetryButton}
            accessibilityLabel={IDS.errorRetryButton}
            style={styles.retryBtn}
            onPress={() => void load()}
          >
            <Text style={styles.buttonText}>Retry</Text>
          </Pressable>
        </View>
      ) : (
        <FlatList
          testID={IDS.videoList}
          accessibilityLabel={IDS.videoList}
          style={styles.list}
          data={visible}
          keyExtractor={(v) => v.id}
          renderItem={({ item }) => <VideoRow item={item} onPress={(v) => void openExternal(v.youtubeUrl)} />}
          refreshControl={<RefreshControl refreshing={refreshing} onRefresh={onRefresh} />}
          ListEmptyComponent={<Text style={styles.dim}>No videos to show.</Text>}
        />
      )}

      {/* Filter panel — a full-cover modal so option text can't collide with list items (§D.2). */}
      <Modal visible={filterOpen} animationType="slide" transparent={false} onRequestClose={() => setFilterOpen(false)}>
        <View style={styles.panel}>
          <Text style={styles.panelTitle}>Filter by category</Text>
          <Pressable
            style={[styles.option, pendingFilter == null && styles.optionSelected]}
            onPress={() => setPendingFilter(null)}
          >
            <Text style={styles.optionText}>All</Text>
          </Pressable>
          {categories.map((c) => (
            <Pressable
              key={c}
              style={[styles.option, pendingFilter === c && styles.optionSelected]}
              onPress={() => setPendingFilter(c)}
            >
              <Text style={styles.optionText}>{c}</Text>
            </Pressable>
          ))}
          <Pressable
            testID={IDS.filterApplyButton}
            accessibilityLabel={IDS.filterApplyButton}
            style={styles.applyBtn}
            onPress={applyFilter}
          >
            <Text style={styles.buttonText}>Apply</Text>
          </Pressable>
        </View>
      </Modal>

      {/* Sort panel. */}
      <Modal visible={sortOpen} animationType="slide" transparent={false} onRequestClose={() => setSortOpen(false)}>
        <View style={styles.panel}>
          <Text style={styles.panelTitle}>Sort</Text>
          {SORT_OPTIONS.map((o) => {
            const selected =
              pendingSort != null && pendingSort.key === o.option.key && pendingSort.dir === o.option.dir;
            return (
              <Pressable
                key={o.label}
                style={[styles.option, selected && styles.optionSelected]}
                onPress={() => setPendingSort(o.option)}
              >
                <Text style={styles.optionText}>{o.label}</Text>
              </Pressable>
            );
          })}
          <Pressable
            testID={IDS.sortApplyButton}
            accessibilityLabel={IDS.sortApplyButton}
            style={styles.applyBtn}
            onPress={applySort}
          >
            <Text style={styles.buttonText}>Apply</Text>
          </Pressable>
        </View>
      </Modal>
    </View>
  );
}

const styles = StyleSheet.create({
  container: { flex: 1, backgroundColor: '#fff', paddingTop: 44 },
  titleRow: { paddingHorizontal: 16, paddingBottom: 6 },
  title: { fontSize: 20, fontWeight: '700', color: '#111' },
  toolbar: { flexDirection: 'row', flexWrap: 'wrap', paddingHorizontal: 10, paddingBottom: 8, gap: 6 },
  headerBtn: { backgroundColor: '#eee', paddingVertical: 8, paddingHorizontal: 12, borderRadius: 6 },
  headerBtnText: { fontSize: 13, color: '#222', fontWeight: '600' },
  list: { flex: 1 },
  row: { flexDirection: 'row', padding: 12, borderBottomWidth: StyleSheet.hairlineWidth, borderBottomColor: '#ddd' },
  thumb: { width: 96, height: 54, borderRadius: 4, backgroundColor: '#ddd' },
  thumbPlaceholder: { backgroundColor: '#ccc' },
  rowText: { flex: 1, marginLeft: 12 },
  rowTitle: { fontSize: 15, fontWeight: '600', color: '#111' },
  rowMeta: { fontSize: 12, color: '#777', marginTop: 2 },
  rowDesc: { fontSize: 12, color: '#555', marginTop: 2 },
  center: { flex: 1, alignItems: 'center', justifyContent: 'center', padding: 24 },
  dim: { color: '#777', marginTop: 8, textAlign: 'center' },
  errorText: { color: '#b00020', fontSize: 16, fontWeight: '600' },
  retryBtn: { marginTop: 16, backgroundColor: '#c4302b', paddingVertical: 10, paddingHorizontal: 24, borderRadius: 8 },
  buttonText: { color: '#fff', fontWeight: '600' },
  panel: { flex: 1, backgroundColor: '#fff', padding: 24, paddingTop: 60 },
  panelTitle: { fontSize: 20, fontWeight: '700', marginBottom: 16, color: '#111' },
  option: { paddingVertical: 14, borderBottomWidth: StyleSheet.hairlineWidth, borderBottomColor: '#eee' },
  optionSelected: { backgroundColor: '#fde8e7' },
  optionText: { fontSize: 16, color: '#222' },
  applyBtn: { marginTop: 24, backgroundColor: '#c4302b', paddingVertical: 14, borderRadius: 8, alignItems: 'center' },
});
