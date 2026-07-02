import React, { useMemo, useRef } from 'react';
import { StyleSheet, View } from 'react-native';
import WebView, { WebViewMessageEvent } from 'react-native-webview';
import { Video } from '../domain/types';

type Props = {
  videos: Video[];
  onMarkerTap: (videoId: string) => void;
};

function buildHtml(videos: Video[]): string {
  const points = videos
    .filter((v) => v.location)
    .map((v) => ({ id: v.id, lat: v.location!.lat, lng: v.location!.lng, title: v.title }));
  const center = points.length > 0 ? points[0] : { lat: 0, lng: 0 };
  return `<!DOCTYPE html>
<html>
<head>
  <meta name="viewport" content="width=device-width, initial-scale=1.0, maximum-scale=1.0" />
  <link rel="stylesheet" href="https://unpkg.com/leaflet@1.9.4/dist/leaflet.css" />
  <style>html,body,#map{height:100%;margin:0;padding:0;}</style>
</head>
<body>
  <div id="map"></div>
  <script src="https://unpkg.com/leaflet@1.9.4/dist/leaflet.js"></script>
  <script>
    var points = ${JSON.stringify(points)};
    var map = L.map('map').setView([${center.lat}, ${center.lng}], points.length > 0 ? 4 : 2);
    L.tileLayer('https://tile.openstreetmap.org/{z}/{x}/{y}.png', {
      attribution: '&copy; OpenStreetMap contributors'
    }).addTo(map);
    points.forEach(function (p) {
      var marker = L.marker([p.lat, p.lng]).addTo(map).bindPopup(p.title);
      marker.on('click', function () {
        if (window.ReactNativeWebView) {
          window.ReactNativeWebView.postMessage(JSON.stringify({ type: 'markerTap', id: p.id }));
        }
      });
    });
  </script>
</body>
</html>`;
}

export function LeafletMap({ videos, onMarkerTap }: Props) {
  const html = useMemo(() => buildHtml(videos), [videos]);
  const webViewRef = useRef<WebView>(null);

  const handleMessage = (event: WebViewMessageEvent) => {
    try {
      const data = JSON.parse(event.nativeEvent.data);
      if (data.type === 'markerTap' && typeof data.id === 'string') {
        onMarkerTap(data.id);
      }
    } catch {
      // ignore malformed messages from the WebView
    }
  };

  return (
    <View style={styles.container}>
      <WebView
        ref={webViewRef}
        originWhitelist={['*']}
        source={{ html }}
        onMessage={handleMessage}
        style={styles.webview}
      />
    </View>
  );
}

const styles = StyleSheet.create({
  container: { flex: 1 },
  webview: { flex: 1 },
});
