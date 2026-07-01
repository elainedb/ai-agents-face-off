import React, { useMemo, useState } from 'react';
import { View, Text, Pressable, StyleSheet, ScrollView } from 'react-native';
import { WebView } from 'react-native-webview';
import { IDS } from './selectors';
import { useVideosStore, useUiStore, useExternalStore } from '../state/stores';
import { isLocated, Video } from '../data/types';

function leafletHtml(markers: { lat: number; lng: number; title: string }[]): string {
  const data = JSON.stringify(markers);
  return `<!DOCTYPE html><html><head>
<meta name="viewport" content="width=device-width, initial-scale=1.0, maximum-scale=1.0" />
<link rel="stylesheet" href="https://unpkg.com/leaflet@1.9.4/dist/leaflet.css" />
<script src="https://unpkg.com/leaflet@1.9.4/dist/leaflet.js"></script>
<style>html,body,#map{height:100%;margin:0;padding:0}</style>
</head><body><div id="map"></div><script>
  var markers = ${data};
  var map = L.map('map');
  L.tileLayer('https://tile.openstreetmap.org/{z}/{x}/{y}.png', { maxZoom: 19, attribution: '© OpenStreetMap' }).addTo(map);
  var group = [];
  markers.forEach(function (m, i) {
    var mk = L.marker([m.lat, m.lng]).addTo(map).bindPopup(m.title);
    mk.on('click', function () {
      if (window.ReactNativeWebView) window.ReactNativeWebView.postMessage(String(i));
    });
    group.push(mk);
  });
  if (group.length) { map.fitBounds(L.featureGroup(group).getBounds().pad(0.2)); }
  else { map.setView([20, 0], 2); }
</script></body></html>`;
}

export default function MapScreen() {
  const all = useVideosStore((s) => s.all);
  const setScreen = useUiStore((s) => s.setScreen);
  const openExternal = useExternalStore((s) => s.open);
  const [selected, setSelected] = useState<Video | null>(null);

  const located = useMemo(() => all.filter(isLocated), [all]);
  const html = useMemo(
    () => leafletHtml(located.map((v) => ({ lat: v.lat as number, lng: v.lng as number, title: v.title }))),
    [located],
  );

  return (
    <View style={styles.container} testID={IDS.screenMap} accessibilityLabel={IDS.screenMap}>
      <View style={styles.header}>
        <Pressable style={styles.backBtn} onPress={() => setScreen('home')}>
          <Text style={styles.backText}>‹ Back</Text>
        </Pressable>
        <Text style={styles.headerTitle}>Map · {located.length} located</Text>
      </View>

      {/* Real OpenStreetMap (Leaflet-in-WebView). Its DOM pins are NOT reachable by the automation
          layer, so the accessible affordance below carries `map_marker` (constitution §5). */}
      <View style={styles.mapWrap}>
        <WebView
          originWhitelist={['*']}
          source={{ html }}
          style={styles.map}
          onMessage={(e) => {
            const idx = parseInt(e.nativeEvent.data, 10);
            if (!Number.isNaN(idx) && located[idx]) setSelected(located[idx]);
          }}
        />
      </View>

      {/* Native, accessible marker affordance — one tappable chip per located video. */}
      <ScrollView horizontal style={styles.chipRow} contentContainerStyle={styles.chipRowContent}>
        {located.map((v) => (
          <Pressable
            key={v.id}
            testID={IDS.mapMarker}
            accessibilityLabel={IDS.mapMarker}
            style={styles.chip}
            onPress={() => setSelected(v)}
          >
            <Text style={styles.chipText} numberOfLines={1}>
              📍 {v.title}
            </Text>
          </Pressable>
        ))}
      </ScrollView>

      {/* Detail bottom sheet — a plain in-tree View (not a separate window), so its testIDs are
          reachable (constitution §5a). */}
      {selected ? (
        <View style={styles.sheet} testID={IDS.detailBottomSheet} accessibilityLabel={IDS.detailBottomSheet}>
          <Text style={styles.sheetTitle}>{selected.title}</Text>
          <Text style={styles.sheetDesc} numberOfLines={2}>
            {selected.description}
          </Text>
          <Text
            testID={IDS.detailVideoUrl}
            accessibilityLabel={IDS.detailVideoUrl}
            style={styles.sheetUrl}
          >
            {selected.youtubeUrl}
          </Text>
          <View style={styles.sheetActions}>
            <Pressable
              testID={IDS.detailOpenYoutubeButton}
              accessibilityLabel={IDS.detailOpenYoutubeButton}
              style={styles.openBtn}
              onPress={() => void openExternal(selected.youtubeUrl)}
            >
              <Text style={styles.buttonText}>Open in YouTube</Text>
            </Pressable>
            <Pressable style={styles.closeBtn} onPress={() => setSelected(null)}>
              <Text style={styles.closeText}>Close</Text>
            </Pressable>
          </View>
        </View>
      ) : null}
    </View>
  );
}

const styles = StyleSheet.create({
  container: { flex: 1, backgroundColor: '#fff', paddingTop: 44 },
  header: { flexDirection: 'row', alignItems: 'center', paddingHorizontal: 12, paddingBottom: 8, gap: 12 },
  backBtn: { paddingVertical: 6, paddingHorizontal: 10, backgroundColor: '#eee', borderRadius: 6 },
  backText: { fontSize: 14, fontWeight: '600', color: '#222' },
  headerTitle: { fontSize: 16, fontWeight: '700', color: '#111' },
  mapWrap: { flex: 1, overflow: 'hidden' },
  map: { flex: 1 },
  chipRow: { maxHeight: 56, backgroundColor: '#fafafa', borderTopWidth: StyleSheet.hairlineWidth, borderTopColor: '#ddd' },
  chipRowContent: { alignItems: 'center', paddingHorizontal: 8, gap: 8 },
  chip: { backgroundColor: '#e8f0fe', paddingVertical: 8, paddingHorizontal: 12, borderRadius: 16, maxWidth: 200 },
  chipText: { fontSize: 13, color: '#1a3a8f', fontWeight: '600' },
  sheet: {
    position: 'absolute',
    left: 0,
    right: 0,
    bottom: 0,
    backgroundColor: '#fff',
    padding: 20,
    borderTopWidth: 1,
    borderTopColor: '#ccc',
    borderTopLeftRadius: 16,
    borderTopRightRadius: 16,
    elevation: 12,
    shadowColor: '#000',
    shadowOpacity: 0.2,
    shadowRadius: 8,
    shadowOffset: { width: 0, height: -2 },
  },
  sheetTitle: { fontSize: 18, fontWeight: '700', color: '#111' },
  sheetDesc: { fontSize: 14, color: '#555', marginTop: 6 },
  sheetUrl: { fontSize: 13, color: '#1a3a8f', marginTop: 10 },
  sheetActions: { flexDirection: 'row', alignItems: 'center', marginTop: 16, gap: 12 },
  openBtn: { backgroundColor: '#c4302b', paddingVertical: 12, paddingHorizontal: 20, borderRadius: 8 },
  closeBtn: { paddingVertical: 12, paddingHorizontal: 16 },
  closeText: { color: '#555', fontWeight: '600' },
  buttonText: { color: '#fff', fontWeight: '600' },
});
