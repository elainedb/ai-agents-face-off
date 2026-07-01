import React, { useMemo } from 'react';
import { Pressable, ScrollView, StyleSheet, Text, View } from 'react-native';
import { WebView } from 'react-native-webview';

import { Video } from '../domain/types';
import { useStore } from '../state/store';

// Build a Leaflet+OSM map (real pins) from the located videos. Per constitution §5 the rendered
// WebView-DOM pins are NOT reachable by Maestro, so the harness affordance is the native
// `map_marker` row below; the WebView pins are the human path (they postMessage taps to native).
function buildHtml(located: Video[]): string {
  const points = located.map((v) => ({
    id: v.id,
    lat: v.location!.lat,
    lng: v.location!.lng,
    title: v.title.replace(/"/g, '&quot;'),
  }));
  const json = JSON.stringify(points);
  return `<!DOCTYPE html><html><head>
<meta name="viewport" content="width=device-width, initial-scale=1.0, maximum-scale=1.0">
<link rel="stylesheet" href="https://unpkg.com/leaflet@1.9.4/dist/leaflet.css"/>
<style>html,body,#map{height:100%;margin:0}</style>
</head><body><div id="map"></div>
<script src="https://unpkg.com/leaflet@1.9.4/dist/leaflet.js"></script>
<script>
  var pts = ${json};
  var map = L.map('map');
  L.tileLayer('https://tile.openstreetmap.org/{z}/{x}/{y}.png', { maxZoom: 19,
    attribution: '&copy; OpenStreetMap' }).addTo(map);
  var group = [];
  pts.forEach(function(p){
    var m = L.marker([p.lat, p.lng]).addTo(map);
    m.on('click', function(){
      if (window.ReactNativeWebView) window.ReactNativeWebView.postMessage(p.id);
    });
    group.push([p.lat, p.lng]);
  });
  if (group.length) map.fitBounds(group, { padding: [40,40] }); else map.setView([0,0], 2);
</script></body></html>`;
}

export function MapScreen() {
  const videos = useStore((s) => s.videos);
  const navigate = useStore((s) => s.navigate);
  const selectVideo = useStore((s) => s.selectVideo);

  const located = useMemo(() => videos.filter((v) => v.location), [videos]);
  const html = useMemo(() => buildHtml(located), [located]);

  const onMessage = (id: string) => {
    const v = located.find((x) => x.id === id);
    if (v) selectVideo(v);
  };

  return (
    <View testID="screen_map" style={styles.container}>
      <View style={styles.header}>
        <Pressable testID="map_back_button" style={styles.backButton} onPress={() => navigate('home')}>
          <Text style={styles.backText}>‹ Back</Text>
        </Pressable>
        <Text style={styles.title}>Map ({located.length})</Text>
      </View>

      <View style={styles.mapWrap}>
        <WebView
          originWhitelist={['*']}
          source={{ html }}
          style={styles.webview}
          onMessage={(e) => onMessage(e.nativeEvent.data)}
          javaScriptEnabled
          domStorageEnabled
        />
      </View>

      {/* Native, accessible marker affordance — one per located video (constitution §5). */}
      <View style={styles.markerBar}>
        <Text style={styles.markerBarLabel}>Markers</Text>
        <ScrollView horizontal showsHorizontalScrollIndicator={false} contentContainerStyle={styles.markerRow}>
          {located.map((v) => (
            <Pressable key={v.id} testID="map_marker" style={styles.marker} onPress={() => selectVideo(v)}>
              <Text style={styles.markerText} numberOfLines={1}>
                {v.title}
              </Text>
            </Pressable>
          ))}
        </ScrollView>
      </View>
    </View>
  );
}

const styles = StyleSheet.create({
  container: { flex: 1, backgroundColor: '#fff' },
  header: { paddingTop: 48, paddingHorizontal: 12, paddingBottom: 8, flexDirection: 'row', alignItems: 'center', gap: 12 },
  backButton: { paddingVertical: 6, paddingHorizontal: 10, backgroundColor: '#eee', borderRadius: 6 },
  backText: { fontSize: 15, fontWeight: '600' },
  title: { fontSize: 20, fontWeight: '700' },
  mapWrap: { flex: 1 },
  webview: { flex: 1 },
  markerBar: { paddingVertical: 10, borderTopWidth: StyleSheet.hairlineWidth, borderTopColor: '#ddd' },
  markerBarLabel: { fontSize: 12, color: '#999', paddingHorizontal: 12, marginBottom: 6 },
  markerRow: { paddingHorizontal: 12, gap: 8 },
  marker: { backgroundColor: '#c00', paddingHorizontal: 14, paddingVertical: 10, borderRadius: 20, maxWidth: 200 },
  markerText: { color: '#fff', fontWeight: '600', fontSize: 14 },
});
