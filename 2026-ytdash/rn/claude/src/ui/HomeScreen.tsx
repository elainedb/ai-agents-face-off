import React, { useEffect, useState } from 'react';
import {
  ActivityIndicator,
  FlatList,
  Image,
  Pressable,
  StyleSheet,
  Text,
  View,
} from 'react-native';
import { resolveConfig } from '../appConfig';
import { availableCategories } from '../domain/filter';
import { Video } from '../domain/models';
import { SORT_OPTIONS } from '../domain/sort';
import { useAuthStore } from '../state/authStore';
import { useExternalStore } from '../state/externalStore';
import { useNavStore } from '../state/navStore';
import { useVideoStore } from '../state/videoStore';

type Panel = 'none' | 'filter' | 'sort';

export function HomeScreen() {
  const cfg = resolveConfig();
  const store = useVideoStore();
  const openExternal = useExternalStore((s) => s.open);
  const logout = useAuthStore((s) => s.logout);
  const go = useNavStore((s) => s.go);
  const [panel, setPanel] = useState<Panel>('none');

  // Safety net: load if we somehow reach home without a load having started.
  useEffect(() => {
    if (store.status === 'idle') void store.load(cfg);
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, []);

  const visible = store.visible();
  const categories = availableCategories(store.all);

  const onLogout = () => {
    setPanel('none');
    go('home');
    logout();
  };

  const renderRow = ({ item }: { item: Video }) => (
    <Pressable
      testID="video_list_item"
      style={styles.row}
      onPress={() => openExternal(item.youtubeUrl, cfg.captureExternalLinks)}
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
          {item.category} · {item.publishedAt.slice(0, 10)}
        </Text>
        <Text style={styles.rowDesc} numberOfLines={2}>
          {item.description}
        </Text>
      </View>
    </Pressable>
  );

  return (
    <View testID="screen_home" style={styles.container}>
      {/* Title bar with the total-loaded count */}
      <View style={styles.header}>
        <Text testID="video_count" style={styles.count}>
          {store.all.length} videos
        </Text>
        {store.stale ? <Text style={styles.staleTag}>offline · cached</Text> : null}
      </View>

      {/* Action bar */}
      <View style={styles.actions}>
        <HeaderButton testID="refresh_control" label="Refresh" onPress={() => store.load(cfg)} />
        <HeaderButton
          testID="filter_button"
          label="Filter"
          onPress={() => setPanel((p) => (p === 'filter' ? 'none' : 'filter'))}
        />
        <HeaderButton
          testID="sort_button"
          label="Sort"
          onPress={() => setPanel((p) => (p === 'sort' ? 'none' : 'sort'))}
        />
        <HeaderButton testID="map_nav_button" label="Map" onPress={() => go('map')} />
        <HeaderButton testID="logout_button" label="Logout" onPress={onLogout} />
      </View>

      {/* Panels REPLACE the list while open so their option text can't collide with row titles. */}
      {panel === 'filter' ? (
        <FilterPanel
          categories={categories}
          active={store.categoryFilter}
          onPick={(c) => {
            store.setFilter(c);
            setPanel('none');
          }}
        />
      ) : panel === 'sort' ? (
        <SortPanel
          active={store.sortKey}
          onPick={(k) => {
            store.setSort(k);
            setPanel('none');
          }}
        />
      ) : (
        <Body store={store} visible={visible} renderRow={renderRow} cfg={cfg} />
      )}
    </View>
  );
}

function Body({
  store,
  visible,
  renderRow,
  cfg,
}: {
  store: ReturnType<typeof useVideoStore.getState>;
  visible: Video[];
  renderRow: ({ item }: { item: Video }) => React.ReactElement;
  cfg: ReturnType<typeof resolveConfig>;
}) {
  if (store.status === 'loading') {
    return (
      <View style={styles.center}>
        <ActivityIndicator testID="loading_indicator" size="large" color="#dc2626" />
        <Text style={styles.centerText}>Loading videos…</Text>
      </View>
    );
  }
  if (store.status === 'error') {
    return (
      <View testID="error_view" style={styles.center}>
        <Text style={styles.errorText}>{store.errorMessage ?? 'Something went wrong.'}</Text>
        <Pressable testID="error_retry_button" style={styles.retry} onPress={() => store.load(cfg)}>
          <Text style={styles.retryText}>Retry</Text>
        </Pressable>
      </View>
    );
  }
  if (visible.length === 0) {
    return (
      <View style={styles.center}>
        <Text style={styles.centerText}>No videos to show.</Text>
      </View>
    );
  }
  return (
    <FlatList
      testID="video_list"
      data={visible}
      keyExtractor={(v) => v.id}
      renderItem={renderRow}
      contentContainerStyle={styles.listContent}
    />
  );
}

function FilterPanel({
  categories,
  active,
  onPick,
}: {
  categories: string[];
  active: string | null;
  onPick: (category: string | null) => void;
}) {
  return (
    <View testID="filter_panel" style={styles.panel}>
      <Text style={styles.panelTitle}>Filter by category</Text>
      <Pressable style={styles.option} onPress={() => onPick(null)}>
        <Text style={[styles.optionText, active === null && styles.optionActive]}>All</Text>
      </Pressable>
      {categories.map((c) => (
        <Pressable key={c} style={styles.option} onPress={() => onPick(c)}>
          <Text style={[styles.optionText, active === c && styles.optionActive]}>{c}</Text>
        </Pressable>
      ))}
    </View>
  );
}

function SortPanel({
  active,
  onPick,
}: {
  active: string;
  onPick: (key: (typeof SORT_OPTIONS)[number]['key']) => void;
}) {
  return (
    <View testID="sort_panel" style={styles.panel}>
      <Text style={styles.panelTitle}>Sort by</Text>
      {SORT_OPTIONS.map((o) => (
        <Pressable key={o.key} style={styles.option} onPress={() => onPick(o.key)}>
          <Text style={[styles.optionText, active === o.key && styles.optionActive]}>{o.label}</Text>
        </Pressable>
      ))}
    </View>
  );
}

function HeaderButton({
  testID,
  label,
  onPress,
}: {
  testID: string;
  label: string;
  onPress: () => void;
}) {
  return (
    <Pressable testID={testID} accessibilityRole="button" onPress={onPress} style={styles.actionBtn}>
      <Text style={styles.actionText}>{label}</Text>
    </Pressable>
  );
}

const styles = StyleSheet.create({
  container: { flex: 1, backgroundColor: '#fff' },
  header: { paddingTop: 48, paddingHorizontal: 16, paddingBottom: 8, flexDirection: 'row', alignItems: 'center' },
  count: { fontSize: 22, fontWeight: '700', color: '#111827' },
  staleTag: { marginLeft: 12, fontSize: 12, color: '#b45309' },
  actions: { flexDirection: 'row', flexWrap: 'wrap', paddingHorizontal: 12, paddingBottom: 8, borderBottomWidth: StyleSheet.hairlineWidth, borderBottomColor: '#e5e7eb' },
  actionBtn: { paddingVertical: 8, paddingHorizontal: 12, margin: 4, backgroundColor: '#f3f4f6', borderRadius: 6 },
  actionText: { fontSize: 13, color: '#1f2937', fontWeight: '600' },
  listContent: { paddingBottom: 24 },
  row: { flexDirection: 'row', padding: 12, borderBottomWidth: StyleSheet.hairlineWidth, borderBottomColor: '#e5e7eb' },
  thumb: { width: 120, height: 68, borderRadius: 6, backgroundColor: '#e5e7eb' },
  thumbPlaceholder: { alignItems: 'center', justifyContent: 'center' },
  rowText: { flex: 1, marginLeft: 12 },
  rowTitle: { fontSize: 15, fontWeight: '600', color: '#111827' },
  rowMeta: { fontSize: 12, color: '#6b7280', marginTop: 2 },
  rowDesc: { fontSize: 12, color: '#9ca3af', marginTop: 2 },
  center: { flex: 1, alignItems: 'center', justifyContent: 'center', padding: 24 },
  centerText: { marginTop: 12, color: '#6b7280' },
  errorText: { color: '#b91c1c', textAlign: 'center', marginBottom: 16 },
  retry: { backgroundColor: '#dc2626', paddingVertical: 10, paddingHorizontal: 24, borderRadius: 6 },
  retryText: { color: '#fff', fontWeight: '600' },
  panel: { flex: 1, padding: 16 },
  panelTitle: { fontSize: 16, fontWeight: '700', color: '#111827', marginBottom: 8 },
  option: { paddingVertical: 14, borderBottomWidth: StyleSheet.hairlineWidth, borderBottomColor: '#e5e7eb' },
  optionText: { fontSize: 16, color: '#1f2937' },
  optionActive: { color: '#dc2626', fontWeight: '700' },
});
