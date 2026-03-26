import { useEffect, useMemo, useRef, useState } from 'react';
import {
  Alert,
  Linking,
  Pressable,
  SafeAreaView,
  StyleSheet,
  Text,
  View,
} from 'react-native';
import { WebView, type WebViewMessageEvent } from 'react-native-webview';
import { router } from 'expo-router';

import type { VideoData } from '@/services/youtubeApi';
import { fetchAllVideos } from '@/services/youtubeApi';

export default function MapScreen() {
  const [videos, setVideos] = useState<VideoData[]>([]);
  const [selectedVideo, setSelectedVideo] = useState<VideoData | null>(null);
  const [loaded, setLoaded] = useState(false);
  const webViewRef = useRef<WebView>(null);

  useEffect(() => {
    void fetchAllVideos()
      .then((allVideos) => {
        const withLocation = allVideos.filter(
          (video) =>
            typeof video.location?.latitude === 'number' &&
            typeof video.location?.longitude === 'number'
        );
        setVideos(withLocation);
      })
      .catch(() => {
        setVideos([]);
      });
  }, []);

  const markerPayload = useMemo(
    () =>
      JSON.stringify(
        videos.map((video) => ({
          id: video.id,
          title: video.title,
          latitude: video.location?.latitude,
          longitude: video.location?.longitude,
        }))
      ),
    [videos]
  );

  useEffect(() => {
    if (!loaded || videos.length === 0) {
      return;
    }

    const timeout = setTimeout(() => {
      webViewRef.current?.injectJavaScript(`
        if (window.__setMarkers) {
          window.__setMarkers(${markerPayload});
        }
        true;
      `);
    }, 250);

    return () => clearTimeout(timeout);
  }, [loaded, markerPayload, videos.length]);

  const mapHtml = useMemo(
    () => `
      <!DOCTYPE html>
      <html>
        <head>
          <meta name="viewport" content="width=device-width, initial-scale=1.0, maximum-scale=1.0">
          <link rel="stylesheet" href="https://unpkg.com/leaflet@1.9.4/dist/leaflet.css" />
          <style>
            html, body, #map { height: 100%; margin: 0; }
            .video-marker {
              align-items: center;
              background: #4285F4;
              border: 2px solid white;
              border-radius: 18px;
              box-shadow: 0 4px 12px rgba(0,0,0,0.25);
              color: white;
              display: flex;
              font-size: 18px;
              height: 36px;
              justify-content: center;
              width: 36px;
            }
          </style>
        </head>
        <body>
          <div id="map"></div>
          <script src="https://unpkg.com/leaflet@1.9.4/dist/leaflet.js"></script>
          <script>
            const map = L.map('map').setView([37.7749, -122.4194], 2);
            const featureGroup = L.featureGroup().addTo(map);
            L.tileLayer('https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png', {
              attribution: '&copy; OpenStreetMap contributors'
            }).addTo(map);

            function postToReactNative(message) {
              if (window.ReactNativeWebView && window.ReactNativeWebView.postMessage) {
                window.ReactNativeWebView.postMessage(JSON.stringify(message));
              }
            }

            function addMarkers(markers) {
              featureGroup.clearLayers();
              markers.forEach((marker) => {
                const icon = L.divIcon({
                  className: '',
                  html: '<div class="video-marker">📷</div>',
                  iconSize: [36, 36],
                  iconAnchor: [18, 18]
                });
                const leafletMarker = L.marker([marker.latitude, marker.longitude], { icon }).addTo(featureGroup);
                leafletMarker.on('click', () => {
                  postToReactNative({ type: 'markerClick', videoId: marker.id });
                });
              });
              if (markers.length > 0) {
                map.fitBounds(featureGroup.getBounds().pad(0.1));
              }
            }

            window.__setMarkers = addMarkers;
          </script>
        </body>
      </html>
    `,
    []
  );

  const handleMessage = (event: WebViewMessageEvent) => {
    try {
      const payload = JSON.parse(event.nativeEvent.data);
      if (payload.type === 'markerClick') {
        const match = videos.find((video) => video.id === payload.videoId) ?? null;
        setSelectedVideo(match);
      }
    } catch {
      // Ignore malformed bridge messages from the webview.
    }
  };

  const openVideo = async (video: VideoData) => {
    const urls = [
      `vnd.youtube://${video.id}`,
      `vnd.youtube://watch?v=${video.id}`,
      `https://m.youtube.com/watch?v=${video.id}`,
      video.videoUrl,
    ];

    for (const url of urls) {
      const canOpen = await Linking.canOpenURL(url);
      if (canOpen) {
        await Linking.openURL(url);
        return;
      }
    }

    Alert.alert('Unable to open video', 'Install the YouTube app or try again later.');
  };

  return (
    <SafeAreaView style={styles.safeArea}>
      <View style={styles.header}>
        <Pressable onPress={() => router.back()} style={styles.headerButton}>
          <Text style={styles.headerButtonText}>{'< Back'}</Text>
        </Pressable>
        <Text style={styles.headerTitle}>Video Locations</Text>
        <View style={styles.headerSpacer} />
      </View>

      {videos.length === 0 ? (
        <View style={styles.emptyState}>
          <Text style={styles.emptyTitle}>No videos with location data found</Text>
          <Pressable onPress={() => router.replace('/main')} style={styles.emptyButton}>
            <Text style={styles.emptyButtonText}>Back to videos</Text>
          </Pressable>
        </View>
      ) : (
        <>
          <WebView
            ref={webViewRef}
            domStorageEnabled
            javaScriptEnabled
            onLoadEnd={() => setLoaded(true)}
            onMessage={handleMessage}
            originWhitelist={['*']}
            source={{ html: mapHtml }}
            style={styles.webView}
          />
          {selectedVideo ? (
            <View style={styles.sheetContainer}>
              <View style={styles.sheetHandle} />
              <View style={styles.sheetContent}>
                <View style={styles.sheetHeader}>
                  <Text style={styles.sheetTitle} numberOfLines={2}>{selectedVideo.title}</Text>
                  <Pressable onPress={() => setSelectedVideo(null)} style={styles.closeButton}>
                    <Text style={styles.closeButtonText}>Close</Text>
                  </Pressable>
                </View>
                <Text style={styles.sheetMeta}>{selectedVideo.channelName}</Text>
                <Text style={styles.sheetMeta}>Published: {selectedVideo.publishedAt.slice(0, 10)}</Text>
                {selectedVideo.recordingDate ? (
                  <Text style={styles.sheetMeta}>Recorded: {selectedVideo.recordingDate}</Text>
                ) : null}
                {selectedVideo.location ? (
                  <Text style={styles.sheetMeta}>
                    Location: {selectedVideo.location.city ?? 'Unknown city'}, {selectedVideo.location.country ?? 'Unknown country'} ({selectedVideo.location.latitude?.toFixed(6)}, {selectedVideo.location.longitude?.toFixed(6)})
                  </Text>
                ) : null}
                {selectedVideo.tags.length > 0 ? (
                  <Text style={styles.sheetMeta}>Tags: {selectedVideo.tags.slice(0, 5).join(', ')}</Text>
                ) : null}
                <Pressable onPress={() => void openVideo(selectedVideo)} style={styles.watchButton}>
                  <Text style={styles.watchButtonText}>Watch on YouTube</Text>
                </Pressable>
              </View>
            </View>
          ) : (
            <View pointerEvents="none" style={styles.hintContainer}>
              <Text style={styles.hintText}>Tap a marker to view video details.</Text>
            </View>
          )}
        </>
      )}
    </SafeAreaView>
  );
}

const styles = StyleSheet.create({
  safeArea: {
    flex: 1,
    backgroundColor: '#f7f9fc',
  },
  header: {
    alignItems: 'center',
    flexDirection: 'row',
    justifyContent: 'space-between',
    paddingHorizontal: 16,
    paddingVertical: 14,
  },
  headerButton: {
    minWidth: 64,
  },
  headerButtonText: {
    color: '#4285F4',
    fontSize: 16,
    fontWeight: '600',
  },
  headerTitle: {
    color: '#14213d',
    fontSize: 20,
    fontWeight: '700',
  },
  headerSpacer: {
    minWidth: 64,
  },
  webView: {
    flex: 1,
  },
  emptyState: {
    alignItems: 'center',
    flex: 1,
    justifyContent: 'center',
    paddingHorizontal: 24,
  },
  emptyTitle: {
    color: '#14213d',
    fontSize: 20,
    fontWeight: '700',
    marginBottom: 16,
    textAlign: 'center',
  },
  emptyButton: {
    backgroundColor: '#4285F4',
    borderRadius: 12,
    paddingHorizontal: 18,
    paddingVertical: 12,
  },
  emptyButtonText: {
    color: '#ffffff',
    fontWeight: '600',
  },
  sheetContent: {
    paddingHorizontal: 20,
    paddingVertical: 12,
  },
  sheetContainer: {
    backgroundColor: '#ffffff',
    borderTopLeftRadius: 20,
    borderTopRightRadius: 20,
    bottom: 0,
    elevation: 10,
    left: 0,
    position: 'absolute',
    right: 0,
    shadowColor: '#000000',
    shadowOffset: { width: 0, height: -4 },
    shadowOpacity: 0.12,
    shadowRadius: 12,
  },
  sheetHandle: {
    alignSelf: 'center',
    backgroundColor: '#cbd5e1',
    borderRadius: 999,
    height: 5,
    marginTop: 10,
    width: 56,
  },
  sheetHeader: {
    alignItems: 'flex-start',
    flexDirection: 'row',
    gap: 12,
    justifyContent: 'space-between',
  },
  sheetTitle: {
    color: '#14213d',
    fontSize: 18,
    flex: 1,
    fontWeight: '700',
    marginBottom: 8,
  },
  sheetMeta: {
    color: '#52627a',
    fontSize: 14,
    marginBottom: 6,
  },
  watchButton: {
    alignItems: 'center',
    backgroundColor: '#FF0000',
    borderRadius: 12,
    marginTop: 12,
    paddingVertical: 12,
  },
  watchButtonText: {
    color: '#ffffff',
    fontWeight: '700',
  },
  closeButton: {
    paddingVertical: 2,
  },
  closeButtonText: {
    color: '#4285F4',
    fontSize: 14,
    fontWeight: '700',
  },
  hintContainer: {
    backgroundColor: 'rgba(20, 33, 61, 0.86)',
    borderRadius: 14,
    bottom: 20,
    left: 20,
    paddingHorizontal: 14,
    paddingVertical: 10,
    position: 'absolute',
    right: 20,
  },
  hintText: {
    color: '#ffffff',
    textAlign: 'center',
  },
});
