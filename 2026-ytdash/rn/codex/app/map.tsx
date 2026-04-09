import { router } from 'expo-router';
import { useState } from 'react';
import {
  Linking,
  Pressable,
  StyleSheet,
  Text,
  View,
} from 'react-native';
import { SafeAreaView } from 'react-native-safe-area-context';
import { Image } from 'expo-image';
import { WebView, type WebViewMessageEvent } from 'react-native-webview';

import type { Video } from '@/src/features/videos/domain/entities/video';
import { hasCoordinates, locationText } from '@/src/features/videos/domain/entities/video';
import { useVideosStore } from '@/src/features/videos/presentation/stores/videos-store';

const buildMapHtml = (videos: Video[]): string => `<!doctype html>
<html>
  <head>
    <meta charset="utf-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <link
      rel="stylesheet"
      href="https://unpkg.com/leaflet@1.9.4/dist/leaflet.css"
      integrity="sha256-p4NxAoJBhIIN+hmNHrzRCf9tD/miZyoHS5obTRR9BMY="
      crossorigin=""
    />
    <style>
      html, body, #map { height: 100%; margin: 0; }
      body { background: #dbe7f7; }
      .leaflet-container { font-family: sans-serif; }
    </style>
  </head>
  <body>
    <div id="map"></div>
    <script src="https://unpkg.com/leaflet@1.9.4/dist/leaflet.js" crossorigin=""></script>
    <script>
      const videos = ${JSON.stringify(
        videos.map((video) => ({
          id: video.id,
          title: video.title,
          latitude: video.latitude,
          longitude: video.longitude,
        }))
      )};
      const map = L.map('map');
      L.tileLayer('https://tile.openstreetmap.org/{z}/{x}/{y}.png', {
        maxZoom: 19,
        attribution: '&copy; OpenStreetMap contributors'
      }).addTo(map);

      const bounds = [];
      videos.forEach((video) => {
        if (typeof video.latitude !== 'number' || typeof video.longitude !== 'number') return;
        const marker = L.marker([video.latitude, video.longitude]).addTo(map);
        marker.on('click', () => {
          window.ReactNativeWebView.postMessage(JSON.stringify({ type: 'markerClick', videoId: video.id }));
        });
        bounds.push([video.latitude, video.longitude]);
      });

      if (bounds.length > 0) {
        map.fitBounds(bounds, { padding: [32, 32] });
      } else {
        map.setView([0, 0], 2);
      }
    </script>
  </body>
</html>`;

export default function MapScreen() {
  const allVideos = useVideosStore((state) => state.allVideos);
  const refreshVideos = useVideosStore((state) => state.refreshVideos);
  const videosWithCoordinates = allVideos.filter(hasCoordinates);
  const [selectedVideoId, setSelectedVideoId] = useState<string | null>(null);

  const selectedVideo = videosWithCoordinates.find((video) => video.id === selectedVideoId) ?? null;

  if (videosWithCoordinates.length === 0) {
    return (
      <SafeAreaView style={styles.safeArea}>
        <View style={styles.header}>
          <Pressable onPress={() => router.back()}>
            <Text style={styles.backButton}>{'< Back'}</Text>
          </Pressable>
          <Text style={styles.headerTitle}>Video Locations</Text>
          <View style={styles.headerSpacer} />
        </View>
        <View style={styles.emptyContainer}>
          <Text style={styles.emptyTitle}>No videos with location data</Text>
          <Text style={styles.emptyText}>Refresh the feed after the API finishes loading recording details.</Text>
          <Pressable style={styles.refreshButton} onPress={() => void refreshVideos()}>
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

      <WebView
        source={{ html: buildMapHtml(videosWithCoordinates) }}
        style={styles.webView}
        applicationNameForUserAgent="dev.elainedb.rn_codex/1.0"
        onMessage={(event: WebViewMessageEvent) => {
          try {
            const payload = JSON.parse(event.nativeEvent.data) as { type?: string; videoId?: string };
            if (payload.type === 'markerClick' && payload.videoId) {
              setSelectedVideoId(payload.videoId);
            }
          } catch {
            setSelectedVideoId(null);
          }
        }}
      />

      {selectedVideo ? (
        <>
          <Pressable style={styles.backdrop} onPress={() => setSelectedVideoId(null)} />
          <View style={styles.bottomSheet}>
            <Pressable style={styles.closeButton} onPress={() => setSelectedVideoId(null)}>
              <Text style={styles.closeButtonText}>Close</Text>
            </Pressable>
            <Image source={{ uri: selectedVideo.thumbnailUrl }} style={styles.sheetThumbnail} contentFit="cover" />
            <Text style={styles.sheetTitle}>{selectedVideo.title}</Text>
            <Text style={styles.sheetChannel}>{selectedVideo.channelName}</Text>
            <Text style={styles.sheetMeta}>Published: {selectedVideo.publishedAt.toISOString().slice(0, 10)}</Text>
            {selectedVideo.recordingDate ? (
              <Text style={styles.sheetMeta}>Recorded: {selectedVideo.recordingDate.toISOString().slice(0, 10)}</Text>
            ) : null}
            <Text style={styles.sheetMeta}>Location: {locationText(selectedVideo)}</Text>
            <Text style={styles.sheetMeta}>
              GPS: {selectedVideo.latitude?.toFixed(4)}, {selectedVideo.longitude?.toFixed(4)}
            </Text>
            {selectedVideo.tags.length > 0 ? (
              <Text style={styles.sheetMeta}>Tags: {selectedVideo.tags.slice(0, 5).join(', ')}</Text>
            ) : null}
            <Pressable
              style={styles.watchButton}
              onPress={() => void Linking.openURL(`https://www.youtube.com/watch?v=${selectedVideo.id}`)}>
              <Text style={styles.watchButtonText}>Watch on YouTube</Text>
            </Pressable>
          </View>
        </>
      ) : null}
    </SafeAreaView>
  );
}

const styles = StyleSheet.create({
  safeArea: {
    flex: 1,
    backgroundColor: '#EEF3FB',
  },
  header: {
    flexDirection: 'row',
    alignItems: 'center',
    justifyContent: 'space-between',
    paddingHorizontal: 16,
    paddingVertical: 12,
    backgroundColor: '#FFFFFF',
    borderBottomWidth: 1,
    borderColor: '#DCE5F2',
  },
  backButton: {
    color: '#4285F4',
    fontWeight: '700',
    width: 60,
  },
  headerTitle: {
    fontSize: 20,
    fontWeight: '800',
    color: '#14213D',
  },
  headerSpacer: {
    width: 60,
  },
  webView: {
    flex: 1,
  },
  emptyContainer: {
    flex: 1,
    alignItems: 'center',
    justifyContent: 'center',
    paddingHorizontal: 24,
  },
  emptyTitle: {
    fontSize: 24,
    fontWeight: '800',
    color: '#14213D',
    marginBottom: 12,
  },
  emptyText: {
    color: '#51627F',
    textAlign: 'center',
    marginBottom: 18,
  },
  refreshButton: {
    borderRadius: 16,
    backgroundColor: '#4285F4',
    paddingHorizontal: 18,
    paddingVertical: 14,
  },
  refreshButtonText: {
    color: '#FFFFFF',
    fontWeight: '700',
  },
  backdrop: {
    ...StyleSheet.absoluteFillObject,
    backgroundColor: 'rgba(9, 16, 32, 0.28)',
  },
  bottomSheet: {
    position: 'absolute',
    left: 16,
    right: 16,
    bottom: 16,
    borderRadius: 24,
    backgroundColor: '#FFFFFF',
    padding: 20,
    gap: 8,
  },
  sheetThumbnail: {
    width: '100%',
    height: 160,
    borderRadius: 16,
    backgroundColor: '#D9E2F2',
  },
  closeButton: {
    alignSelf: 'flex-end',
  },
  closeButtonText: {
    color: '#51627F',
    fontWeight: '700',
  },
  sheetTitle: {
    fontSize: 20,
    fontWeight: '800',
    color: '#14213D',
  },
  sheetChannel: {
    color: '#4285F4',
    fontWeight: '700',
  },
  sheetMeta: {
    color: '#4C5B75',
  },
  watchButton: {
    marginTop: 10,
    borderRadius: 16,
    backgroundColor: '#FF0000',
    paddingVertical: 14,
    alignItems: 'center',
  },
  watchButtonText: {
    color: '#FFFFFF',
    fontWeight: '700',
  },
});
