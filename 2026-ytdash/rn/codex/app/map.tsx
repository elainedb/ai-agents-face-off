import { useEffect, useMemo, useRef, useState } from 'react';
import { Image } from 'expo-image';
import {
  ActivityIndicator,
  Alert,
  Animated,
  Linking,
  Pressable,
  SafeAreaView,
  StyleSheet,
  Text,
  View,
} from 'react-native';
import { useRouter } from 'expo-router';
import { WebView, type WebViewMessageEvent } from 'react-native-webview';

import { fetchAllVideos } from '@/services/youtubeApi';
import type { VideoData } from '@/types/video';

const INITIAL_COORDINATES = {
  latitude: 37.7749,
  longitude: -122.4194,
  zoom: 2,
};

export default function MapScreen() {
  const router = useRouter();
  const [videos, setVideos] = useState<VideoData[]>([]);
  const [isLoading, setIsLoading] = useState(true);
  const [selectedVideo, setSelectedVideo] = useState<VideoData | null>(null);
  const mapHtml = useMemo(() => buildMapHtml(videos), [videos]);
  const sheetTranslateY = useRef(new Animated.Value(420)).current;

  useEffect(() => {
    void loadVideos();
  }, []);

  async function loadVideos() {
    setIsLoading(true);

    try {
      const allVideos = await fetchAllVideos();
      setVideos(
        allVideos.filter(
          (video) =>
            typeof video.location?.latitude === 'number' &&
            typeof video.location?.longitude === 'number'
        )
      );
    } catch (error) {
      console.warn('Failed to load videos for map', error);
      setVideos([]);
    } finally {
      setIsLoading(false);
    }
  }

  function handleMessage(event: WebViewMessageEvent) {
    try {
      const payload = JSON.parse(event.nativeEvent.data) as { type?: string; videoId?: string };
      if (payload.type !== 'markerClick' || !payload.videoId) {
        return;
      }

      const nextVideo = videos.find((video) => video.id === payload.videoId) ?? null;
      setSelectedVideo(nextVideo);
      if (nextVideo) {
        Animated.spring(sheetTranslateY, {
          toValue: 0,
          useNativeDriver: true,
          damping: 20,
          stiffness: 180,
        }).start();
      }
    } catch (error) {
      console.warn('Failed to parse WebView message', error);
    }
  }

  function closeSheet() {
    Animated.timing(sheetTranslateY, {
      toValue: 420,
      duration: 220,
      useNativeDriver: true,
    }).start(({ finished }) => {
      if (finished) {
        setSelectedVideo(null);
      }
    });
  }

  async function openVideo(video: VideoData) {
    try {
      await openYouTubeVideo(video.id, video.videoUrl);
    } catch (error) {
      console.warn('Failed to open YouTube video from map', error);
      Alert.alert('Unable to open video', 'Install the YouTube app or try again later.');
    }
  }

  return (
    <SafeAreaView style={styles.safeArea}>
      <View style={styles.header}>
        <Pressable onPress={() => router.back()} style={styles.backButton}>
          <Text style={styles.backButtonText}>{'< Back'}</Text>
        </Pressable>
        <Text style={styles.headerTitle}>Video Locations</Text>
        <View style={styles.headerSpacer} />
      </View>

      {isLoading ? (
        <View style={styles.centeredContent}>
          <ActivityIndicator size="large" color="#4285F4" />
        </View>
      ) : videos.length === 0 ? (
        <View style={styles.centeredContent}>
          <Text style={styles.emptyTitle}>No videos with location data found</Text>
          <Pressable onPress={() => void loadVideos()} style={styles.refreshButton}>
            <Text style={styles.refreshButtonText}>Refresh</Text>
          </Pressable>
        </View>
      ) : (
        <>
          <WebView
            key={`map-${videos.length}`}
            source={{ html: mapHtml }}
            style={styles.webView}
            onMessage={handleMessage}
            originWhitelist={['*']}
            javaScriptEnabled
            domStorageEnabled
          />
          {selectedVideo ? (
            <>
              <Pressable style={styles.sheetBackdrop} onPress={closeSheet} />
              <Animated.View
                style={[
                  styles.sheetContainer,
                  {
                    transform: [{ translateY: sheetTranslateY }],
                  },
                ]}>
                <View style={styles.sheetHandle} />
                <View style={styles.sheetContent}>
                  <Image
                    source={{ uri: selectedVideo.thumbnailUrl }}
                    style={styles.sheetThumbnail}
                    contentFit="cover"
                  />
                  <Text style={styles.sheetTitle} numberOfLines={2}>
                    {selectedVideo.title}
                  </Text>
                  <Text style={styles.sheetSubtitle}>{selectedVideo.channelName}</Text>
                  <Text style={styles.sheetMeta}>Published: {selectedVideo.publishedAt.slice(0, 10)}</Text>
                  {selectedVideo.recordingDate ? (
                    <Text style={styles.sheetMeta}>Recorded: {selectedVideo.recordingDate}</Text>
                  ) : null}
                  {selectedVideo.location ? (
                    <Text style={styles.sheetMeta}>
                      {`📍 ${selectedVideo.location.city ?? 'Unknown city'}, ${
                        selectedVideo.location.country ?? 'Unknown country'
                      } (${selectedVideo.location.latitude?.toFixed(6)}, ${selectedVideo.location.longitude?.toFixed(6)})`}
                    </Text>
                  ) : null}
                  {selectedVideo.tags.length ? (
                    <Text style={styles.sheetTags}>{selectedVideo.tags.slice(0, 5).join(', ')}</Text>
                  ) : null}
                  <Pressable
                    onPress={() => void openVideo(selectedVideo)}
                    style={styles.youtubeButton}>
                    <Text style={styles.youtubeButtonText}>Watch on YouTube</Text>
                  </Pressable>
                </View>
              </Animated.View>
            </>
          ) : null}
        </>
      )}
    </SafeAreaView>
  );
}

function buildMapHtml(videos: VideoData[]) {
  const markersJson = JSON.stringify(
    videos.map((video) => ({
      id: video.id,
      title: video.title,
      latitude: video.location?.latitude,
      longitude: video.location?.longitude,
    }))
  );

  return `<!DOCTYPE html>
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
      body { font-family: Arial, sans-serif; }
      .video-marker {
        width: 34px;
        height: 34px;
        border-radius: 17px;
        background: #4285F4;
        border: 2px solid white;
        box-shadow: 0 8px 18px rgba(15, 23, 42, 0.25);
        display: flex;
        align-items: center;
        justify-content: center;
        color: white;
        font-size: 18px;
      }
    </style>
  </head>
  <body>
    <div id="map"></div>
    <script src="https://unpkg.com/leaflet@1.9.4/dist/leaflet.js"
      integrity="sha256-20nQCchB9co0qIjJZRGuk2/Z9VM+kNiyxNV1lvTlZBo="
      crossorigin=""></script>
    <script>
      const map = L.map('map').setView([${INITIAL_COORDINATES.latitude}, ${INITIAL_COORDINATES.longitude}], ${INITIAL_COORDINATES.zoom});
      const featureGroup = L.featureGroup().addTo(map);
      const markers = ${markersJson};

      L.tileLayer('https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png', {
        attribution: '&copy; OpenStreetMap contributors'
      }).addTo(map);

      function postToReactNative(payload) {
        if (!window.ReactNativeWebView || typeof window.ReactNativeWebView.postMessage !== 'function') {
          return;
        }

        window.ReactNativeWebView.postMessage(JSON.stringify(payload));
      }

      function renderMarkers() {
        try {
          if (!Array.isArray(markers)) {
            return;
          }

          featureGroup.clearLayers();

          markers.forEach((marker) => {
            if (typeof marker.latitude !== 'number' || typeof marker.longitude !== 'number') {
              return;
            }

            const icon = L.divIcon({
              className: '',
              html: '<div class="video-marker">📷</div>',
              iconSize: [34, 34],
              iconAnchor: [17, 17],
            });

            const leafletMarker = L.marker([marker.latitude, marker.longitude], { icon }).addTo(featureGroup);
            const notifyReactNative = function() {
              postToReactNative({
                type: 'markerClick',
                videoId: marker.id,
              });
            };

            leafletMarker.on('click', notifyReactNative);
            leafletMarker.on('mousedown', notifyReactNative);
            leafletMarker.on('touchstart', notifyReactNative);
          });

          if (featureGroup.getLayers().length) {
            map.fitBounds(featureGroup.getBounds().pad(0.1));
          }
        } catch (error) {
          postToReactNative({
            type: 'mapError',
            message: String(error),
          });
        }
      }

      setTimeout(renderMarkers, 100);
    </script>
  </body>
</html>`;
}

async function openYouTubeVideo(videoId: string, fallbackUrl: string) {
  const candidates = [
    `intent://www.youtube.com/watch?v=${videoId}#Intent;package=com.google.android.youtube;scheme=https;end`,
    `vnd.youtube://${videoId}`,
    `vnd.youtube://watch?v=${videoId}`,
    `https://www.youtube.com/watch?v=${videoId}`,
    `https://m.youtube.com/watch?v=${videoId}`,
    fallbackUrl,
  ];

  let lastError: unknown;

  for (const url of candidates) {
    try {
      await Linking.openURL(url);
      return;
    } catch (error) {
      lastError = error;
    }
  }

  throw lastError ?? new Error('No supported YouTube URL could be opened.');
}

const styles = StyleSheet.create({
  safeArea: {
    flex: 1,
    backgroundColor: '#f7f9fc',
  },
  header: {
    flexDirection: 'row',
    alignItems: 'center',
    justifyContent: 'space-between',
    paddingHorizontal: 16,
    paddingVertical: 12,
  },
  backButton: {
    minWidth: 68,
  },
  backButtonText: {
    color: '#4285F4',
    fontSize: 16,
    fontWeight: '600',
  },
  headerTitle: {
    fontSize: 20,
    fontWeight: '700',
    color: '#101828',
  },
  headerSpacer: {
    minWidth: 68,
  },
  centeredContent: {
    flex: 1,
    alignItems: 'center',
    justifyContent: 'center',
    paddingHorizontal: 24,
    gap: 16,
  },
  emptyTitle: {
    fontSize: 20,
    fontWeight: '700',
    color: '#101828',
    textAlign: 'center',
  },
  refreshButton: {
    borderRadius: 12,
    backgroundColor: '#4285F4',
    paddingHorizontal: 18,
    paddingVertical: 12,
  },
  refreshButtonText: {
    color: '#ffffff',
    fontWeight: '700',
  },
  webView: {
    flex: 1,
  },
  sheetBackdrop: {
    ...StyleSheet.absoluteFillObject,
    backgroundColor: 'rgba(16, 24, 40, 0.15)',
  },
  sheetContainer: {
    position: 'absolute',
    left: 0,
    right: 0,
    bottom: 0,
    backgroundColor: '#ffffff',
    borderTopLeftRadius: 24,
    borderTopRightRadius: 24,
    shadowColor: '#101828',
    shadowOpacity: 0.18,
    shadowRadius: 20,
    shadowOffset: { width: 0, height: -6 },
    elevation: 12,
    minHeight: 280,
    paddingBottom: 24,
  },
  sheetHandle: {
    alignSelf: 'center',
    width: 48,
    height: 5,
    borderRadius: 999,
    backgroundColor: '#d0d5dd',
    marginTop: 10,
  },
  sheetContent: {
    paddingHorizontal: 20,
    paddingVertical: 8,
  },
  sheetThumbnail: {
    width: 80,
    height: 60,
    borderRadius: 10,
    backgroundColor: '#d0d5dd',
    marginBottom: 12,
  },
  sheetTitle: {
    fontSize: 18,
    fontWeight: '700',
    color: '#101828',
    marginBottom: 6,
  },
  sheetSubtitle: {
    color: '#344054',
    fontWeight: '600',
    marginBottom: 10,
  },
  sheetMeta: {
    color: '#475467',
    marginBottom: 8,
    lineHeight: 20,
  },
  sheetTags: {
    color: '#667085',
    fontStyle: 'italic',
    marginBottom: 16,
  },
  youtubeButton: {
    marginTop: 8,
    alignItems: 'center',
    borderRadius: 14,
    backgroundColor: '#FF0000',
    paddingVertical: 14,
  },
  youtubeButtonText: {
    color: '#ffffff',
    fontWeight: '700',
  },
});
