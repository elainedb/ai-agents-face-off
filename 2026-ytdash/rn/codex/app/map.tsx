import { Image } from 'expo-image';
import { useRouter } from 'expo-router';
import { useEffect, useMemo, useRef, useState } from 'react';
import {
  Animated,
  Pressable,
  StyleSheet,
  Text,
  View,
} from 'react-native';
import { SafeAreaView } from 'react-native-safe-area-context';
import { WebView } from 'react-native-webview';

import { openVideo } from '@/src/features/videos/presentation/components/VideoItem';
import { Video } from '@/src/features/videos/domain/entities/video';
import { hasCoordinates } from '@/src/features/videos/domain/utils/video-utils';
import { useVideosStore } from '@/src/features/videos/presentation/stores/videos-store';

const MAP_HTML = `
<!DOCTYPE html>
<html>
  <head>
    <meta name="viewport" content="width=device-width, initial-scale=1.0, maximum-scale=1.0" />
    <link
      rel="stylesheet"
      href="https://unpkg.com/leaflet@1.9.4/dist/leaflet.css"
      integrity="sha256-p4NxAoJBhIIN+hmNHrzRCf9tD/miZyoHS5obTRR9BMY="
      crossorigin=""
    />
    <style>
      html, body, #map { height: 100%; margin: 0; padding: 0; }
      body { background: #dbe7f5; }
    </style>
  </head>
  <body>
    <div id="map"></div>
    <script src="https://unpkg.com/leaflet@1.9.4/dist/leaflet.js"
      integrity="sha256-20nQCchB9co0qIjJZRGuk2/Z9VM+kNiyxNV1lvTlZBo="
      crossorigin=""></script>
    <script>
      const map = L.map('map').setView([20, 0], 2);
      L.tileLayer('https://tile.openstreetmap.org/{z}/{x}/{y}.png', {
        maxZoom: 19,
        attribution: '&copy; OpenStreetMap contributors'
      }).addTo(map);
      const markers = [];
      window.setMarkers = function (payload) {
        markers.forEach((marker) => marker.remove());
        markers.length = 0;
        payload.forEach((video) => {
          const marker = L.marker([video.latitude, video.longitude]).addTo(map);
          marker.on('click', function () {
            window.ReactNativeWebView.postMessage(JSON.stringify({ type: 'markerClick', videoId: video.id }));
          });
          markers.push(marker);
        });
        if (markers.length > 0) {
          const bounds = L.featureGroup(markers).getBounds().pad(0.2);
          map.fitBounds(bounds);
        }
      };
    </script>
  </body>
</html>
`;

export default function MapScreen() {
  const router = useRouter();
  const webViewRef = useRef<WebView>(null);
  const panelTranslateY = useRef(new Animated.Value(320)).current;
  const allVideos = useVideosStore((state) => state.allVideos);
  const refreshVideos = useVideosStore((state) => state.refreshVideos);
  const [selectedVideo, setSelectedVideo] = useState<Video | null>(null);

  const locationVideos = useMemo(
    () => allVideos.filter((video) => hasCoordinates(video)),
    [allVideos],
  );

  useEffect(() => {
    Animated.timing(panelTranslateY, {
      toValue: selectedVideo ? 0 : 320,
      duration: 220,
      useNativeDriver: true,
    }).start();
  }, [panelTranslateY, selectedVideo]);

  useEffect(() => {
    if (!webViewRef.current) {
      return;
    }

    webViewRef.current.injectJavaScript(`
      window.setMarkers(${JSON.stringify(locationVideos)});
      true;
    `);
  }, [locationVideos]);

  if (locationVideos.length === 0) {
    return (
      <SafeAreaView style={styles.safeArea}>
        <View style={styles.header}>
          <Pressable onPress={() => router.back()}>
            <Text style={styles.backButton}>{'< Back'}</Text>
          </Pressable>
          <Text style={styles.headerTitle}>Video Locations</Text>
          <View style={styles.headerSpacer} />
        </View>
        <View style={styles.emptyState}>
          <Text style={styles.emptyText}>
            No videos with location data are available yet. Refresh the feed and try again.
          </Text>
          <Pressable onPress={() => refreshVideos().catch(() => undefined)} style={styles.refreshButton}>
            <Text style={styles.refreshButtonText}>Refresh Videos</Text>
          </Pressable>
        </View>
      </SafeAreaView>
    );
  }

  return (
    <SafeAreaView style={styles.safeArea}>
      <View style={styles.header}>
        <Pressable onPress={() => router.back()}>
          <Text style={styles.backButton}>{'< Back'}</Text>
        </Pressable>
        <Text style={styles.headerTitle}>Video Locations</Text>
        <View style={styles.headerSpacer} />
      </View>

      <View style={styles.mapContainer}>
        <WebView
          ref={webViewRef}
          source={{ html: MAP_HTML }}
          onLoadEnd={() => {
            if (!webViewRef.current) {
              return;
            }

            webViewRef.current.injectJavaScript(`
              window.setMarkers(${JSON.stringify(locationVideos)});
              true;
            `);
          }}
          onMessage={(event) => {
            const message = JSON.parse(event.nativeEvent.data) as {
              type?: string;
              videoId?: string;
            };

            if (message.type === 'markerClick' && message.videoId) {
              setSelectedVideo(locationVideos.find((video) => video.id === message.videoId) ?? null);
            }
          }}
          userAgent="dev.elainedb.rn_codex/1.0"
          style={styles.map}
        />
      </View>

      {selectedVideo ? (
        <>
          <Pressable style={styles.backdrop} onPress={() => setSelectedVideo(null)} />
          <Animated.View
            pointerEvents="box-none"
            style={[styles.panel, { transform: [{ translateY: panelTranslateY }] }]}>
            <View style={styles.panelHeader}>
              <Text style={styles.panelTitle}>Video Details</Text>
              <Pressable onPress={() => setSelectedVideo(null)}>
                <Text style={styles.closeButton}>Close</Text>
              </Pressable>
            </View>
            <Image source={selectedVideo.thumbnailUrl} style={styles.thumbnail} contentFit="cover" />
            <Text style={styles.videoTitle}>{selectedVideo.title}</Text>
            <Text style={styles.videoMeta}>{selectedVideo.channelName}</Text>
            <Text style={styles.videoMeta}>
              Published: {selectedVideo.publishedAt.toISOString().slice(0, 10)}
            </Text>
            {selectedVideo.recordingDate ? (
              <Text style={styles.videoMeta}>
                Recorded: {selectedVideo.recordingDate.toISOString().slice(0, 10)}
              </Text>
            ) : null}
            <Text style={styles.videoMeta}>
              {[selectedVideo.city, selectedVideo.country].filter(Boolean).join(', ')}
            </Text>
            <Text style={styles.videoMeta}>
              GPS: {selectedVideo.latitude?.toFixed(4)}, {selectedVideo.longitude?.toFixed(4)}
            </Text>
            {selectedVideo.tags.length > 0 ? (
              <Text style={styles.videoMeta}>Tags: {selectedVideo.tags.slice(0, 5).join(', ')}</Text>
            ) : null}
            <Pressable
              onPress={() => openVideo(selectedVideo.id).catch(() => undefined)}
              style={styles.youtubeButton}>
              <Text style={styles.youtubeButtonText}>Watch on YouTube</Text>
            </Pressable>
          </Animated.View>
        </>
      ) : null}
    </SafeAreaView>
  );
}

const styles = StyleSheet.create({
  safeArea: {
    flex: 1,
    backgroundColor: '#f4f7fb',
  },
  header: {
    flexDirection: 'row',
    alignItems: 'center',
    justifyContent: 'space-between',
    paddingHorizontal: 16,
    paddingVertical: 12,
    backgroundColor: '#fff',
    borderBottomWidth: 1,
    borderBottomColor: '#dde5ef',
  },
  backButton: {
    color: '#4285F4',
    fontWeight: '700',
    fontSize: 16,
  },
  headerTitle: {
    color: '#102030',
    fontWeight: '800',
    fontSize: 18,
  },
  headerSpacer: {
    width: 56,
  },
  mapContainer: {
    flex: 1,
  },
  map: {
    flex: 1,
  },
  emptyState: {
    flex: 1,
    alignItems: 'center',
    justifyContent: 'center',
    paddingHorizontal: 30,
    gap: 16,
  },
  emptyText: {
    textAlign: 'center',
    color: '#51667d',
    lineHeight: 22,
  },
  refreshButton: {
    backgroundColor: '#4285F4',
    borderRadius: 14,
    paddingHorizontal: 18,
    paddingVertical: 12,
  },
  refreshButtonText: {
    color: '#fff',
    fontWeight: '700',
  },
  backdrop: {
    ...StyleSheet.absoluteFillObject,
    backgroundColor: 'rgba(9, 18, 29, 0.35)',
  },
  panel: {
    position: 'absolute',
    left: 0,
    right: 0,
    bottom: 0,
    backgroundColor: '#fff',
    borderTopLeftRadius: 24,
    borderTopRightRadius: 24,
    padding: 18,
    gap: 8,
  },
  panelHeader: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'center',
  },
  panelTitle: {
    fontWeight: '800',
    fontSize: 18,
    color: '#102030',
  },
  closeButton: {
    color: '#4285F4',
    fontWeight: '700',
  },
  thumbnail: {
    height: 170,
    borderRadius: 16,
    backgroundColor: '#d9e3ef',
  },
  videoTitle: {
    color: '#102030',
    fontWeight: '700',
    fontSize: 18,
  },
  videoMeta: {
    color: '#51667d',
    fontSize: 13,
  },
  youtubeButton: {
    marginTop: 8,
    backgroundColor: '#FF0000',
    borderRadius: 14,
    paddingVertical: 14,
    alignItems: 'center',
  },
  youtubeButtonText: {
    color: '#fff',
    fontWeight: '700',
  },
});
