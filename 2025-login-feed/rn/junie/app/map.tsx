import React, { useEffect, useMemo, useRef, useState, useCallback } from 'react';
import { View, Text, StyleSheet, ActivityIndicator, Image, TouchableOpacity, Linking } from 'react-native';
import { WebView } from 'react-native-webview';
import BottomSheet, { BottomSheetView } from '@gorhom/bottom-sheet';
import { SafeAreaView } from 'react-native-safe-area-context';
import { fetchCombinedChannelVideosCached, formatDateYYYYMMDD, YoutubeVideo } from '../utils/youtube';

const CHANNEL_IDS = [
  'UCynoa1DjwnvHAowA_jiMEAQ',
  'UCK0KOjX3beyB9nzonls0cuw',
  'UCACkIrvrGAQ7kuc0hMVwvmA',
  'UCtWRAKKvOEA0CXOue9BG8ZA',
];

export default function MapScreen() {
  const [videos, setVideos] = useState<YoutubeVideo[]>([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);
  const [selected, setSelected] = useState<YoutubeVideo | null>(null);

  const sheetRef = useRef<BottomSheet | null>(null);
  const snapPoints = useMemo(() => ['12%', '25%'], []);

  // Compute markers from videos with coordinates
  const markers = useMemo(() => {
    return videos
      .filter(v => typeof v.locationLat === 'number' && typeof v.locationLng === 'number')
      .map(v => ({
        id: v.id,
        title: v.title,
        lat: v.locationLat as number,
        lng: v.locationLng as number,
        city: v.locationCity,
        country: v.locationCountry,
      }));
  }, [videos]);

  const load = async () => {
    setError(null);
    try {
      const data = await fetchCombinedChannelVideosCached(CHANNEL_IDS, 100);
      setVideos(data);
    } catch (e: any) {
      setError(e?.message || 'Failed to load videos.');
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => {
    load();
  }, []);

  const openYouTube = useCallback((videoId?: string) => {
    if (!videoId) return;
    const url = `https://www.youtube.com/watch?v=${videoId}`;
    Linking.openURL(url).catch(() => {});
  }, []);

  const handleMessage = useCallback((event: any) => {
    try {
      const data = JSON.parse(event?.nativeEvent?.data || '{}');
      if (data?.type === 'select' && data?.id) {
        const vid = videos.find(v => v.id === data.id);
        if (vid) {
          setSelected(vid);
          requestAnimationFrame(() => sheetRef.current?.expand());
        }
      }
    } catch {
      // ignore
    }
  }, [videos]);

  const html = useMemo(() => buildLeafletHtml(markers), [markers]);

  if (loading) {
    return (
      <View style={styles.center}>
        <ActivityIndicator />
        <Text style={styles.loadingText}>Loading map…</Text>
      </View>
    );
  }

  return (
    <SafeAreaView style={styles.container} edges={['top']}>
      {!!error && <Text style={styles.error}>{error}</Text>}

      <WebView
        style={styles.map}
        originWhitelist={["*"]}
        source={{ html, baseUrl: 'https://localhost' }}
        onMessage={handleMessage}
        javaScriptEnabled
        domStorageEnabled
        allowsInlineMediaPlayback
        mixedContentMode="always"
      />

      <BottomSheet ref={sheetRef} snapPoints={snapPoints} enablePanDownToClose index={-1}>
        <BottomSheetView>
          {selected ? (
            <TouchableOpacity style={styles.sheetContent} activeOpacity={0.8} onPress={() => openYouTube(selected.id)}>
              {!!selected.thumbnailUrl && (
                <Image source={{ uri: selected.thumbnailUrl }} style={styles.thumb} />
              )}
              <View style={{ flex: 1, marginLeft: 12 }}>
                <Text style={styles.title} numberOfLines={2}>{selected.title}</Text>
                <Text style={styles.sub}>Channel: {selected.channelTitle}</Text>
                <Text style={styles.sub}>Published: {formatDateYYYYMMDD(selected.publishedAt)}</Text>
                {selected.recordingDate && (
                  <Text style={styles.sub}>Recorded: {formatDateYYYYMMDD(selected.recordingDate)}</Text>
                )}
                {(selected.locationCity || selected.locationCountry || (selected.locationLat && selected.locationLng)) && (
                  <Text style={styles.sub} numberOfLines={2}>
                    Location: {[selected.locationCity, selected.locationCountry].filter(Boolean).join(', ')}
                    {selected.locationLat !== undefined && selected.locationLng !== undefined ? ` (${selected.locationLat?.toFixed(4)}, ${selected.locationLng?.toFixed(4)})` : ''}
                  </Text>
                )}
                {!!selected.tags?.length && (
                  <Text style={styles.sub} numberOfLines={2}>Tags: {selected.tags.join(', ')}</Text>
                )}
                <View style={{ marginTop: 8 }}>
                  <Text style={styles.link}>Tap to open in YouTube</Text>
                </View>
              </View>
            </TouchableOpacity>
          ) : (
            <View style={styles.sheetEmpty}>
              <Text style={styles.sub}>Tap a marker to see details.</Text>
            </View>
          )}
        </BottomSheetView>
      </BottomSheet>
    </SafeAreaView>
  );
}

function buildLeafletHtml(markers: { id: string; title: string; lat: number; lng: number; city?: string; country?: string }[]) {
  const markersJson = JSON.stringify(markers);
  return `<!doctype html>
<html>
  <head>
    <meta charset="utf-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1, maximum-scale=1" />
    <link rel="stylesheet" href="https://unpkg.com/leaflet@1.9.4/dist/leaflet.css" integrity="sha256-p4NxAoJBhIIN+hmNHrzRCf9tD/miZyoHS5obTRR9BMY=" crossorigin="" />
    <style>
      html, body, #map { height: 100%; margin: 0; padding: 0; }
      .leaflet-control-attribution { font-size: 11px; }
    </style>
  </head>
  <body>
    <div id="map"></div>
    <script src="https://unpkg.com/leaflet@1.9.4/dist/leaflet.js" integrity="sha256-20nQCchB9co0qIjJZRGuk2/Z9VM+kNiyxNV1lvTlZBo=" crossorigin=""></script>
    <script>
      (function() {
        var markers = ${markersJson};
        var map = L.map('map', { zoomControl: true });
        var tiles = L.tileLayer('https://tile.openstreetmap.org/{z}/{x}/{y}.png', {
          maxZoom: 19,
          attribution: '&copy; <a href="https://www.openstreetmap.org/copyright">OpenStreetMap</a> contributors'
        }).addTo(map);

        if (markers.length > 0) {
          var bounds = [];
          markers.forEach(function(m) {
            var marker = L.marker([m.lat, m.lng]).addTo(map);
            var label = [m.city, m.country].filter(Boolean).join(', ');
            if (label) marker.bindPopup(label);
            marker.on('click', function() {
              try {
                window.ReactNativeWebView && window.ReactNativeWebView.postMessage(JSON.stringify({ type: 'select', id: m.id }));
              } catch (e) {}
            });
            bounds.push([m.lat, m.lng]);
          });
          map.fitBounds(bounds, { padding: [40, 40] });
        } else {
          map.setView([20, 0], 2);
        }
      })();
    </script>
  </body>
</html>`;
}

const styles = StyleSheet.create({
  container: { flex: 1 },
  center: { flex: 1, alignItems: 'center', justifyContent: 'center' },
  loadingText: { marginTop: 8 },
  error: { color: 'red', textAlign: 'center', padding: 8 },
  map: { flex: 1 },
  sheetContent: {
    flexDirection: 'row',
    alignItems: 'center',
    paddingHorizontal: 12,
    paddingVertical: 10,
  },
  sheetEmpty: {
    paddingHorizontal: 12,
    paddingVertical: 10,
  },
  thumb: { width: 100, height: 56, borderRadius: 4, backgroundColor: '#eee' },
  title: { fontSize: 16, fontWeight: '600' },
  sub: { fontSize: 12, color: '#444', marginTop: 2 },
  link: { color: '#1e88e5', fontSize: 13, fontWeight: '500' },
});
