import BottomSheet, { BottomSheetView } from '@gorhom/bottom-sheet';
import { Image } from 'expo-image';
import * as Linking from 'expo-linking';
import { useRef, useState } from 'react';
import { Pressable, SafeAreaView, StyleSheet, Text, View } from 'react-native';
import { router } from 'expo-router';
import { WebView } from 'react-native-webview';

import { getContainer } from '@/src/core/di/container';
import type { Video } from '@/src/features/videos/domain/entities/video';
import { hasCoordinates, locationText } from '@/src/features/videos/domain/utils/video-utils';

const formatDate = (date: Date | null) => (date ? date.toISOString().slice(0, 10) : 'N/A');

const openVideo = async (videoId: string) => {
  const webUrl = `https://www.youtube.com/watch?v=${videoId}`;
  await Linking.openURL(webUrl);
};

const escapeHtmlJson = (value: unknown) =>
  JSON.stringify(value).replace(/</g, '\\u003c').replace(/>/g, '\\u003e');

const buildMapHtml = (videos: Video[]) => {
  const markers = videos.map((video) => ({
    id: video.id,
    title: video.title,
    channelName: video.channelName,
    city: video.city,
    country: video.country,
    latitude: video.latitude,
    longitude: video.longitude,
  }));

  return `<!DOCTYPE html>
<html lang="en">
  <head>
    <meta charset="utf-8" />
    <meta
      name="viewport"
      content="width=device-width, initial-scale=1, maximum-scale=1, user-scalable=no"
    />
    <link
      rel="stylesheet"
      href="https://unpkg.com/leaflet@1.9.4/dist/leaflet.css"
      integrity="sha256-p4NxAoJBhIIN+hmNHrzRCf9tD/miZyoHS5obTRR9BMY="
      crossorigin=""
    />
    <style>
      html, body, #map {
        height: 100%;
        margin: 0;
        padding: 0;
        background: #dfe9ff;
      }

      .leaflet-container {
        font-family: sans-serif;
      }

      .popup-title {
        font-weight: 700;
        margin-bottom: 4px;
      }

      .popup-meta {
        color: #4c5f82;
        font-size: 12px;
      }
    </style>
  </head>
  <body>
    <div id="map"></div>
    <script
      src="https://unpkg.com/leaflet@1.9.4/dist/leaflet.js"
      integrity="sha256-20nQCchB9co0qIjJZRGuk2/Z9VM+kNiyxNV1lvTlZBo="
      crossorigin=""
    ></script>
    <script>
      const markers = ${escapeHtmlJson(markers)};

      const map = L.map('map', {
        zoomControl: true,
        preferCanvas: true,
      });

      L.tileLayer('https://tile.openstreetmap.org/{z}/{x}/{y}.png', {
        maxZoom: 19,
        minZoom: 2,
        attribution: '&copy; OpenStreetMap contributors',
      }).addTo(map);

      const bounds = [];

      markers.forEach((marker) => {
        if (marker.latitude == null || marker.longitude == null) {
          return;
        }

        const leafletMarker = L.marker([marker.latitude, marker.longitude]).addTo(map);
        bounds.push([marker.latitude, marker.longitude]);

        const location = [marker.city, marker.country].filter(Boolean).join(', ') || 'Location unavailable';
        leafletMarker.bindPopup(
          '<div class="popup-title">' +
            marker.title +
            '</div><div class="popup-meta">' +
            marker.channelName +
            '<br/>' +
            location +
            '</div>'
        );

        leafletMarker.on('click', () => {
          window.ReactNativeWebView.postMessage(
            JSON.stringify({ type: 'markerPress', videoId: marker.id })
          );
        });
      });

      if (bounds.length === 1) {
        map.setView(bounds[0], 6);
      } else if (bounds.length > 1) {
        map.fitBounds(bounds, { padding: [32, 32] });
      } else {
        map.setView([20, 0], 2);
      }
    </script>
  </body>
</html>`;
};

export default function MapScreen() {
  const videosStore = getContainer().videosStore;
  const videos = videosStore((state) => state.allVideos).filter(hasCoordinates);
  const sheetRef = useRef<BottomSheet | null>(null);
  const [selectedVideo, setSelectedVideo] = useState<Video | null>(null);

  const handleMessage = (payload: string) => {
    try {
      const parsed = JSON.parse(payload) as { type?: string; videoId?: string };
      if (parsed.type !== 'markerPress' || !parsed.videoId) {
        return;
      }

      const match = videos.find((video) => video.id === parsed.videoId) ?? null;
      setSelectedVideo(match);

      if (match) {
        sheetRef.current?.snapToIndex(0);
      }
    } catch {
      return;
    }
  };

  return (
    <SafeAreaView style={styles.container}>
      <View style={styles.header}>
        <Pressable onPress={() => router.back()}>
          <Text style={styles.backButton}>&lt; Back</Text>
        </Pressable>
        <Text style={styles.title}>Video Locations</Text>
        <View style={styles.headerSpacer} />
      </View>

      {videos.length === 0 ? (
        <View style={styles.emptyState}>
          <Text style={styles.emptyTitle}>No videos with coordinates</Text>
          <Text style={styles.emptyText}>
            Refresh the feed after videos with location metadata are available.
          </Text>
          <Pressable
            style={styles.refreshButton}
            onPress={() => void videosStore.getState().refreshVideos()}>
            <Text style={styles.refreshButtonText}>Refresh</Text>
          </Pressable>
        </View>
      ) : (
        <>
          <WebView
            style={styles.map}
            source={{ html: buildMapHtml(videos) }}
            originWhitelist={['*']}
            onMessage={(event) => handleMessage(event.nativeEvent.data)}
            javaScriptEnabled
            domStorageEnabled
            userAgent="dev.elainedb.rn_claude/1.0"
          />
          <BottomSheet ref={sheetRef} index={-1} snapPoints={['25%', '48%']} enablePanDownToClose>
            <BottomSheetView style={styles.sheetContent}>
              {selectedVideo ? (
                <>
                  <Image source={{ uri: selectedVideo.thumbnailUrl }} style={styles.sheetImage} />
                  <Text style={styles.sheetTitle}>{selectedVideo.title}</Text>
                  <Text style={styles.sheetChannel}>{selectedVideo.channelName}</Text>
                  <Text style={styles.sheetMeta}>
                    Published: {formatDate(selectedVideo.publishedAt)}
                  </Text>
                  <Text style={styles.sheetMeta}>
                    Recorded: {formatDate(selectedVideo.recordingDate)}
                  </Text>
                  <Text style={styles.sheetMeta}>Location: {locationText(selectedVideo)}</Text>
                  <Text style={styles.sheetMeta}>
                    GPS: {selectedVideo.latitude?.toFixed(4)}, {selectedVideo.longitude?.toFixed(4)}
                  </Text>
                  <Text style={styles.sheetMeta}>
                    Tags: {selectedVideo.tags.slice(0, 5).join(', ') || 'None'}
                  </Text>
                  <Pressable
                    style={styles.watchButton}
                    onPress={() => void openVideo(selectedVideo.id)}>
                    <Text style={styles.watchButtonText}>Watch on YouTube</Text>
                  </Pressable>
                </>
              ) : null}
            </BottomSheetView>
          </BottomSheet>
        </>
      )}
    </SafeAreaView>
  );
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: '#f4f7ff',
  },
  header: {
    flexDirection: 'row',
    alignItems: 'center',
    justifyContent: 'space-between',
    paddingHorizontal: 16,
    paddingVertical: 12,
  },
  backButton: {
    color: '#1a4ea3',
    fontWeight: '700',
  },
  title: {
    fontSize: 20,
    fontWeight: '800',
    color: '#13203a',
  },
  headerSpacer: {
    width: 48,
  },
  map: {
    flex: 1,
    backgroundColor: '#dfe9ff',
  },
  emptyState: {
    flex: 1,
    alignItems: 'center',
    justifyContent: 'center',
    gap: 12,
    paddingHorizontal: 24,
  },
  emptyTitle: {
    fontSize: 22,
    fontWeight: '800',
    color: '#13203a',
  },
  emptyText: {
    color: '#607192',
    textAlign: 'center',
  },
  refreshButton: {
    backgroundColor: '#4285F4',
    borderRadius: 14,
    paddingHorizontal: 20,
    paddingVertical: 12,
  },
  refreshButtonText: {
    color: '#ffffff',
    fontWeight: '700',
  },
  sheetContent: {
    flex: 1,
    gap: 8,
    padding: 16,
  },
  sheetImage: {
    width: '100%',
    height: 140,
    borderRadius: 14,
    backgroundColor: '#d7def2',
  },
  sheetTitle: {
    fontSize: 18,
    fontWeight: '800',
    color: '#13203a',
  },
  sheetChannel: {
    fontWeight: '700',
    color: '#4c5f82',
  },
  sheetMeta: {
    color: '#617393',
  },
  watchButton: {
    marginTop: 8,
    borderRadius: 14,
    paddingVertical: 14,
    alignItems: 'center',
    backgroundColor: '#FF0000',
  },
  watchButtonText: {
    color: '#ffffff',
    fontWeight: '700',
  },
});
