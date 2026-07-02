import { useMemo, useState } from 'react';
import { Pressable, StyleSheet, Text, View } from 'react-native';
import { WebView, WebViewMessageEvent } from 'react-native-webview';

import { Video } from '../../domain/types';
import { useExternalLinkStore } from '../../state/externalLinkStore';
import { useNavStore } from '../../state/navStore';
import { useVideoStore } from '../../state/videoStore';
import { DetailBottomSheet } from '../components/DetailBottomSheet';
import { MapMarkersOverlay } from '../components/MapMarkersOverlay';

function buildMapHtml(located: Video[]): string {
  const points = located
    .filter((v) => v.location)
    .map((v) => ({ id: v.id, lat: v.location!.lat, lng: v.location!.lng, title: v.title.replace(/'/g, "\\'") }));

  const center = points.length > 0 ? points[0] : { lat: 0, lng: 0 };

  return `<!DOCTYPE html>
<html>
<head>
  <meta name="viewport" content="width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no" />
  <link rel="stylesheet" href="https://unpkg.com/leaflet@1.9.4/dist/leaflet.css" />
  <style>html, body, #map { height: 100%; margin: 0; padding: 0; }</style>
</head>
<body>
  <div id="map"></div>
  <script src="https://unpkg.com/leaflet@1.9.4/dist/leaflet.js"></script>
  <script>
    const map = L.map('map').setView([${center.lat}, ${center.lng}], 3);
    L.tileLayer('https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png', {
      attribution: '&copy; OpenStreetMap contributors',
    }).addTo(map);
    const points = ${JSON.stringify(points)};
    points.forEach((p) => {
      const marker = L.marker([p.lat, p.lng]).addTo(map).bindPopup(p.title);
      // Human path: tapping a rendered pin also opens the native detail sheet. Maestro cannot
      // reach this (WebView DOM), so it drives the native map_marker chips instead — the
      // uniform contract constitution.md §5 requires.
      marker.on('click', () => {
        if (window.ReactNativeWebView) window.ReactNativeWebView.postMessage(p.id);
      });
    });
  </script>
</body>
</html>`;
}

export function MapScreen() {
  const videos = useVideoStore((s) => s.videos);
  const goHome = useNavStore((s) => s.goHome);
  const openExternal = useExternalLinkStore((s) => s.open);
  const [selected, setSelected] = useState<Video | null>(null);

  const located = useMemo(() => videos.filter((v) => v.location), [videos]);
  const html = useMemo(() => buildMapHtml(located), [located]);

  function handleWebViewMessage(event: WebViewMessageEvent) {
    const id = event.nativeEvent.data;
    const video = located.find((v) => v.id === id);
    if (video) setSelected(video);
  }

  return (
    <View testID="screen_map" style={styles.container}>
      <View style={styles.header}>
        <Pressable onPress={goHome} style={styles.backButton}>
          <Text style={styles.backText}>Back</Text>
        </Pressable>
        <Text style={styles.title}>Map</Text>
      </View>
      <WebView source={{ html }} style={styles.webview} onMessage={handleWebViewMessage} originWhitelist={['*']} />
      <MapMarkersOverlay videos={located} onSelect={setSelected} />
      {selected ? (
        <DetailBottomSheet
          video={selected}
          onClose={() => setSelected(null)}
          onOpenYoutube={(video) => openExternal(video.youtubeUrl)}
        />
      ) : null}
    </View>
  );
}

const styles = StyleSheet.create({
  container: { flex: 1, backgroundColor: '#fff' },
  header: { paddingTop: 48, paddingHorizontal: 16, paddingBottom: 8, flexDirection: 'row', alignItems: 'center', gap: 12 },
  backButton: { paddingVertical: 6, paddingHorizontal: 12, backgroundColor: '#f2f2f2', borderRadius: 6 },
  backText: { color: '#1a73e8', fontWeight: '600', fontSize: 13 },
  title: { fontSize: 18, fontWeight: '700' },
  webview: { flex: 1 },
});
