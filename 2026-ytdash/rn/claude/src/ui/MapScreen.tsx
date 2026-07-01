import React, { useMemo, useRef, useState } from 'react';
import { Pressable, ScrollView, StyleSheet, Text, View } from 'react-native';
import { WebView } from 'react-native-webview';
import { resolveConfig } from '../appConfig';
import { Video } from '../domain/models';
import { useExternalStore } from '../state/externalStore';
import { useNavStore } from '../state/navStore';
import { useVideoStore } from '../state/videoStore';

// OpenStreetMap via Leaflet in a WebView (the idiomatic RN map stack). Per constitution §5 the
// DOM-rendered pins are NOT reachable by the black-box harness, so we ALSO render a native,
// accessible `map_marker` chip per located video — that is the affordance Maestro taps. Human taps
// on the real pins postMessage back and select the same video.
function leafletHtml(located: Video[]): string {
  const markers = located.map((v, i) => ({
    lat: v.location!.lat,
    lng: v.location!.lng,
    title: v.title.replace(/'/g, ' '),
    idx: i,
  }));
  const center = markers.length ? [markers[0].lat, markers[0].lng] : [20, 0];
  return `<!DOCTYPE html><html><head>
<meta name="viewport" content="width=device-width, initial-scale=1.0, maximum-scale=1.0" />
<link rel="stylesheet" href="https://unpkg.com/leaflet@1.9.4/dist/leaflet.css" />
<script src="https://unpkg.com/leaflet@1.9.4/dist/leaflet.js"></script>
<style>html,body,#map{height:100%;margin:0;padding:0}</style>
</head><body><div id="map"></div><script>
  var markers = ${JSON.stringify(markers)};
  try {
    var map = L.map('map').setView([${center[0]}, ${center[1]}], 3);
    L.tileLayer('https://tile.openstreetmap.org/{z}/{x}/{y}.png', { maxZoom: 19,
      attribution: '&copy; OpenStreetMap' }).addTo(map);
    markers.forEach(function(m) {
      var mk = L.marker([m.lat, m.lng]).addTo(map).bindPopup(m.title);
      mk.on('click', function() {
        if (window.ReactNativeWebView) window.ReactNativeWebView.postMessage(String(m.idx));
      });
    });
  } catch (e) {}
</script></body></html>`;
}

export function MapScreen() {
  const cfg = resolveConfig();
  const all = useVideoStore((s) => s.all);
  const openExternal = useExternalStore((s) => s.open);
  const go = useNavStore((s) => s.go);
  const [selected, setSelected] = useState<Video | null>(null);
  const webRef = useRef<WebView>(null);

  const located = useMemo(() => all.filter((v) => v.location), [all]);
  const html = useMemo(() => leafletHtml(located), [located]);

  return (
    <View testID="screen_map" style={styles.container}>
      <View style={styles.header}>
        <Pressable testID="map_back_button" onPress={() => go('home')} style={styles.backBtn}>
          <Text style={styles.backText}>‹ List</Text>
        </Pressable>
        <Text style={styles.title}>Map · {located.length} located</Text>
      </View>

      <View style={styles.mapWrap}>
        <WebView
          ref={webRef}
          testID="map_webview"
          originWhitelist={['*']}
          source={{ html }}
          style={styles.web}
          onMessage={(e) => {
            const idx = parseInt(e.nativeEvent.data, 10);
            if (!Number.isNaN(idx) && located[idx]) setSelected(located[idx]);
          }}
        />
      </View>

      {/* Native, accessible marker affordance — one chip per located video. */}
      <View style={styles.markerBar}>
        <Text style={styles.markerBarLabel}>Markers</Text>
        <ScrollView horizontal showsHorizontalScrollIndicator={false}>
          {located.map((v) => (
            <Pressable
              key={v.id}
              testID="map_marker"
              style={styles.marker}
              onPress={() => setSelected(v)}
            >
              <Text style={styles.markerText} numberOfLines={1}>
                {v.title}
              </Text>
            </Pressable>
          ))}
        </ScrollView>
      </View>

      {/* Detail sheet — a plain absolutely-positioned View (not a separate window), so its testIDs
          are reachable with no extra work (cross-framework-setup.md §C). */}
      {selected ? (
        <View testID="detail_bottom_sheet" style={styles.sheet}>
          <Text style={styles.sheetTitle}>{selected.title}</Text>
          <Text style={styles.sheetMeta}>
            {selected.category} · {selected.publishedAt.slice(0, 10)}
          </Text>
          <Text testID="detail_video_url" style={styles.sheetUrl}>
            {selected.youtubeUrl}
          </Text>
          <View style={styles.sheetActions}>
            <Pressable
              testID="detail_open_youtube_button"
              style={styles.openBtn}
              onPress={() => openExternal(selected.youtubeUrl, cfg.captureExternalLinks)}
            >
              <Text style={styles.openText}>Open in YouTube</Text>
            </Pressable>
            <Pressable
              testID="detail_close_button"
              style={styles.closeBtn}
              onPress={() => setSelected(null)}
            >
              <Text style={styles.closeText}>Close</Text>
            </Pressable>
          </View>
        </View>
      ) : null}
    </View>
  );
}

const styles = StyleSheet.create({
  container: { flex: 1, backgroundColor: '#fff' },
  header: { paddingTop: 48, paddingHorizontal: 16, paddingBottom: 8, flexDirection: 'row', alignItems: 'center' },
  backBtn: { paddingVertical: 6, paddingRight: 16 },
  backText: { fontSize: 16, color: '#dc2626', fontWeight: '600' },
  title: { fontSize: 18, fontWeight: '700', color: '#111827' },
  mapWrap: { flex: 1, backgroundColor: '#e5e7eb' },
  web: { flex: 1, backgroundColor: '#e5e7eb' },
  markerBar: { paddingVertical: 8, paddingHorizontal: 12, borderTopWidth: StyleSheet.hairlineWidth, borderTopColor: '#e5e7eb' },
  markerBarLabel: { fontSize: 12, color: '#6b7280', marginBottom: 6 },
  marker: { backgroundColor: '#dc2626', paddingVertical: 8, paddingHorizontal: 14, borderRadius: 16, marginRight: 8 },
  markerText: { color: '#fff', fontSize: 13, fontWeight: '600', maxWidth: 160 },
  sheet: { position: 'absolute', left: 0, right: 0, bottom: 0, backgroundColor: '#fff', padding: 20, paddingBottom: 32, borderTopLeftRadius: 16, borderTopRightRadius: 16, elevation: 12, shadowColor: '#000', shadowOpacity: 0.2, shadowRadius: 12, shadowOffset: { width: 0, height: -2 } },
  sheetTitle: { fontSize: 18, fontWeight: '700', color: '#111827' },
  sheetMeta: { fontSize: 13, color: '#6b7280', marginTop: 4 },
  sheetUrl: { fontSize: 13, color: '#2563eb', marginTop: 10 },
  sheetActions: { flexDirection: 'row', marginTop: 16, alignItems: 'center' },
  openBtn: { backgroundColor: '#dc2626', paddingVertical: 12, paddingHorizontal: 20, borderRadius: 8 },
  openText: { color: '#fff', fontWeight: '600' },
  closeBtn: { marginLeft: 16, paddingVertical: 12, paddingHorizontal: 12 },
  closeText: { color: '#6b7280', fontWeight: '600' },
});
