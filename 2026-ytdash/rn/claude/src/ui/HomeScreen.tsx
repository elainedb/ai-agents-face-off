import React, { useMemo, useState } from 'react';
import { FlatList, Image, Pressable, StyleSheet, Text, View } from 'react-native';

import { availableLabels, filterVideos } from '../domain/filter';
import { sortVideos, SORT_OPTIONS } from '../domain/sort';
import { ALL_FILTER, SortKey, Video } from '../domain/types';
import { useStore } from '../state/store';
import { EmptyView, ErrorView, LoadingView } from './StateViews';

type Panel = 'none' | 'filter' | 'sort';

export function HomeScreen() {
  const status = useStore((s) => s.status);
  const error = useStore((s) => s.error);
  const videos = useStore((s) => s.videos);
  const refreshing = useStore((s) => s.refreshing);
  const filterLabel = useStore((s) => s.filterLabel);
  const sortKey = useStore((s) => s.sortKey);
  const loadVideos = useStore((s) => s.loadVideos);
  const refresh = useStore((s) => s.refresh);
  const setFilter = useStore((s) => s.setFilter);
  const setSort = useStore((s) => s.setSort);
  const navigate = useStore((s) => s.navigate);
  const signOut = useStore((s) => s.signOut);
  const openExternal = useStore((s) => s.openExternal);

  // Derive the visible list here (memoized) rather than via a store selector: a selector that
  // returns a fresh filtered/sorted array each call would fail zustand's Object.is snapshot check
  // and loop forever ("Maximum update depth exceeded").
  const visible = useMemo(() => {
    const filtered = filterVideos(videos, filterLabel);
    return sortKey ? sortVideos(filtered, sortKey) : filtered;
  }, [videos, filterLabel, sortKey]);

  const [panel, setPanel] = useState<Panel>('none');
  const [menuOpen, setMenuOpen] = useState(false);
  const [pendingFilter, setPendingFilter] = useState<string>(filterLabel);
  const [pendingSort, setPendingSort] = useState<SortKey | null>(sortKey);

  const labels = availableLabels(videos);

  return (
    <View testID="screen_home" style={styles.container}>
      {/* Header with the total loaded count + controls */}
      <View style={styles.header}>
        <Text testID="video_count" style={styles.title}>
          Videos ({videos.length})
        </Text>
        <View style={styles.headerButtons}>
          <HeaderButton id="refresh_control" label="↻" onPress={() => refresh()} />
          <HeaderButton
            id="filter_button"
            label="Filter"
            onPress={() => {
              setPendingFilter(filterLabel);
              setPanel(panel === 'filter' ? 'none' : 'filter');
            }}
          />
          <HeaderButton
            id="sort_button"
            label="Sort"
            onPress={() => {
              setPendingSort(sortKey);
              setPanel(panel === 'sort' ? 'none' : 'sort');
            }}
          />
          <HeaderButton id="map_nav_button" label="Map" onPress={() => navigate('map')} />
          <HeaderButton id="overflow_menu_button" label="⋮" onPress={() => setMenuOpen((v) => !v)} />
        </View>
      </View>

      {/* Overflow menu (kept in the main view tree so its testIDs stay reachable, §5a) */}
      {menuOpen ? (
        <View style={styles.menu}>
          <Pressable
            testID="logout_button"
            style={styles.menuItem}
            onPress={() => {
              setMenuOpen(false);
              signOut();
            }}
          >
            <Text style={styles.menuItemText}>Log out</Text>
          </Pressable>
        </View>
      ) : null}

      {/* Body: the filter/sort panel REPLACES the list while open (cross-framework-setup §D.2) */}
      {panel === 'filter' ? (
        <SelectionPanel
          title="Filter by category"
          options={[{ key: ALL_FILTER, label: 'All' }, ...labels.map((l) => ({ key: l, label: l }))]}
          selectedKey={pendingFilter}
          onSelect={(key) => setPendingFilter(key)}
          applyTestId="filter_apply_button"
          onApply={() => {
            setFilter(pendingFilter);
            setPanel('none');
          }}
        />
      ) : panel === 'sort' ? (
        <SelectionPanel
          title="Sort by"
          options={SORT_OPTIONS.map((o) => ({ key: o.key, label: o.label }))}
          selectedKey={pendingSort ?? ''}
          onSelect={(key) => setPendingSort(key as SortKey)}
          applyTestId="sort_apply_button"
          onApply={() => {
            if (pendingSort) setSort(pendingSort);
            setPanel('none');
          }}
        />
      ) : (
        <ListBody
          status={status}
          error={error}
          visible={visible}
          refreshing={refreshing}
          onRetry={loadVideos}
          onOpen={(v) => openExternal(v.youtubeUrl)}
        />
      )}
    </View>
  );
}

function ListBody({
  status,
  error,
  visible,
  refreshing,
  onRetry,
  onOpen,
}: {
  status: string;
  error: string | null;
  visible: Video[];
  refreshing: boolean;
  onRetry: () => void;
  onOpen: (v: Video) => void;
}) {
  if (status === 'loading') return <LoadingView />;
  if (status === 'error') return <ErrorView message={error} onRetry={onRetry} />;
  if (status === 'empty' || visible.length === 0) {
    // Keep the list container present (with its testID) even when empty, so the harness can still
    // resolve `video_list`; show an empty hint below it.
    return (
      <View style={styles.flex}>
        <FlatList testID="video_list" data={[]} renderItem={null} />
        <EmptyView />
      </View>
    );
  }
  return (
    <FlatList
      testID="video_list"
      style={styles.flex}
      data={visible}
      keyExtractor={(v) => v.id}
      refreshing={refreshing}
      onRefresh={onRetry}
      renderItem={({ item }) => <VideoRow video={item} onPress={() => onOpen(item)} />}
    />
  );
}

function VideoRow({ video, onPress }: { video: Video; onPress: () => void }) {
  return (
    <Pressable testID="video_list_item" style={styles.row} onPress={onPress}>
      <Image source={{ uri: video.thumbnailUrl }} style={styles.thumb} />
      <View style={styles.rowText}>
        <Text style={styles.rowTitle} numberOfLines={2}>
          {video.title}
        </Text>
        <Text style={styles.rowDesc} numberOfLines={2}>
          {video.description}
        </Text>
        <Text style={styles.rowMeta}>
          {video.category} · {video.publishedAt.slice(0, 10)}
        </Text>
      </View>
    </Pressable>
  );
}

function SelectionPanel({
  title,
  options,
  selectedKey,
  onSelect,
  applyTestId,
  onApply,
}: {
  title: string;
  options: { key: string; label: string }[];
  selectedKey: string;
  onSelect: (key: string) => void;
  applyTestId: string;
  onApply: () => void;
}) {
  return (
    <View style={styles.panel}>
      <Text style={styles.panelTitle}>{title}</Text>
      {options.map((o) => (
        <Pressable
          key={o.key}
          style={[styles.option, selectedKey === o.key && styles.optionSelected]}
          onPress={() => onSelect(o.key)}
        >
          <Text style={styles.optionText}>{o.label}</Text>
        </Pressable>
      ))}
      <Pressable testID={applyTestId} style={styles.applyButton} onPress={onApply}>
        <Text style={styles.applyText}>Apply</Text>
      </Pressable>
    </View>
  );
}

function HeaderButton({ id, label, onPress }: { id: string; label: string; onPress: () => void }) {
  return (
    <Pressable testID={id} style={styles.headerButton} onPress={onPress}>
      <Text style={styles.headerButtonText}>{label}</Text>
    </Pressable>
  );
}

const styles = StyleSheet.create({
  container: { flex: 1, backgroundColor: '#fff' },
  flex: { flex: 1 },
  header: {
    paddingTop: 48,
    paddingHorizontal: 12,
    paddingBottom: 8,
    borderBottomWidth: StyleSheet.hairlineWidth,
    borderBottomColor: '#ddd',
  },
  title: { fontSize: 20, fontWeight: '700', marginBottom: 8 },
  headerButtons: { flexDirection: 'row', flexWrap: 'wrap', gap: 6 },
  headerButton: { backgroundColor: '#eee', paddingHorizontal: 12, paddingVertical: 8, borderRadius: 6 },
  headerButtonText: { fontSize: 14, fontWeight: '600', color: '#222' },
  menu: {
    position: 'absolute',
    top: 96,
    right: 12,
    backgroundColor: '#fff',
    borderRadius: 8,
    borderWidth: StyleSheet.hairlineWidth,
    borderColor: '#ccc',
    elevation: 6,
    zIndex: 20,
  },
  menuItem: { paddingHorizontal: 20, paddingVertical: 14 },
  menuItemText: { fontSize: 16, color: '#222' },
  row: { flexDirection: 'row', padding: 12, gap: 12, borderBottomWidth: StyleSheet.hairlineWidth, borderBottomColor: '#eee' },
  thumb: { width: 96, height: 54, borderRadius: 4, backgroundColor: '#ddd' },
  rowText: { flex: 1 },
  rowTitle: { fontSize: 16, fontWeight: '600', color: '#111' },
  rowDesc: { fontSize: 13, color: '#555', marginTop: 2 },
  rowMeta: { fontSize: 12, color: '#999', marginTop: 4 },
  panel: { flex: 1, padding: 16, gap: 8 },
  panelTitle: { fontSize: 18, fontWeight: '700', marginBottom: 8 },
  option: { paddingVertical: 14, paddingHorizontal: 12, borderRadius: 8, backgroundColor: '#f2f2f2' },
  optionSelected: { backgroundColor: '#d7e6ff', borderWidth: 1, borderColor: '#4285F4' },
  optionText: { fontSize: 16, color: '#111' },
  applyButton: { marginTop: 16, backgroundColor: '#c00', paddingVertical: 14, borderRadius: 8, alignItems: 'center' },
  applyText: { color: '#fff', fontWeight: '700', fontSize: 16 },
});
