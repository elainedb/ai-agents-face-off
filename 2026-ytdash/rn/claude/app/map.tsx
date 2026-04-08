import React, { useRef, useState } from 'react';
import {
  View,
  Text,
  TouchableOpacity,
  StyleSheet,
  Animated,
  Dimensions,
  Linking,
  Alert,
  Platform,
  StatusBar,
  SafeAreaView,
  ScrollView,
} from 'react-native';
import { WebView } from 'react-native-webview';
import { Image } from 'expo-image';
import { router } from 'expo-router';
import { useVideosStore } from '@/src/features/videos/presentation/stores/videos-store';
import type { Video } from '@/src/features/videos/domain/entities/video';
import { hasCoordinates, locationText } from '@/src/features/videos/domain/entities/video';

const { height: SCREEN_HEIGHT } = Dimensions.get('window');
const BOTTOM_SHEET_HEIGHT = SCREEN_HEIGHT * 0.35;

async function openVideo(videoId: string): Promise<void> {
  const isIOS = Platform.OS === 'ios';
  const appUrl = isIOS ? `youtube://watch?v=${videoId}` : `vnd.youtube:${videoId}`;
  const altAppUrl = `youtube://watch?v=${videoId}`;
  const webUrl = `https://www.youtube.com/watch?v=${videoId}`;

  try {
    await Linking.openURL(appUrl);
  } catch {
    if (!isIOS) {
      try {
        await Linking.openURL(altAppUrl);
      } catch {
        try {
          await Linking.openURL(webUrl);
        } catch {
          Alert.alert('Error', 'Cannot open video.');
        }
      }
    } else {
      try {
        await Linking.openURL(webUrl);
      } catch {
        Alert.alert('Error', 'Cannot open video.');
      }
    }
  }
}

function formatDate(date: Date): string {
  return date.toISOString().split('T')[0];
}

function buildMapHtml(videos: Video[]): string {
  const markers = videos.map((v) => ({
    id: v.id,
    lat: v.latitude,
    lng: v.longitude,
    title: v.title.replace(/'/g, "\\'").replace(/\n/g, ' '),
  }));

  return `<!DOCTYPE html>
<html>
<head>
  <meta name="viewport" content="width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no">
  <link rel="stylesheet" href="https://unpkg.com/leaflet@1.9.4/dist/leaflet.css" />
  <script src="https://unpkg.com/leaflet@1.9.4/dist/leaflet.js"></script>
  <style>
    * { margin: 0; padding: 0; }
    #map { width: 100vw; height: 100vh; }
  </style>
</head>
<body>
  <div id="map"></div>
  <script>
    try {
      var map = L.map('map', { zoomControl: true }).setView([0, 0], 2);
      L.tileLayer('https://tile.openstreetmap.org/{z}/{x}/{y}.png', {
        maxZoom: 19,
        attribution: '&copy; OpenStreetMap contributors'
      }).addTo(map);

      var markers = ${JSON.stringify(markers)};
      var bounds = [];

      markers.forEach(function(m) {
        var marker = L.marker([m.lat, m.lng]).addTo(map);
        marker.bindTooltip(m.title, { direction: 'top' });
        marker.on('click', function() {
          window.ReactNativeWebView.postMessage(JSON.stringify({ type: 'markerClick', videoId: m.id }));
        });
        bounds.push([m.lat, m.lng]);
      });

      if (bounds.length > 0) {
        map.fitBounds(bounds, { padding: [40, 40] });
      }

      window.ReactNativeWebView.postMessage(JSON.stringify({ type: 'mapReady' }));
    } catch(e) {
      window.ReactNativeWebView.postMessage(JSON.stringify({ type: 'mapError', message: e.message }));
    }
  </script>
</body>
</html>`;
}

export default function MapScreen() {
  const { allVideos, refreshVideos } = useVideosStore();
  const webViewRef = useRef<WebView>(null);
  const slideAnim = useRef(new Animated.Value(BOTTOM_SHEET_HEIGHT)).current;
  const [selectedVideo, setSelectedVideo] = useState<Video | null>(null);
  const geoVideos = allVideos.filter(hasCoordinates);

  const showSheet = (video: Video) => {
    setSelectedVideo(video);
    Animated.spring(slideAnim, {
      toValue: 0,
      useNativeDriver: true,
    }).start();
  };

  const hideSheet = () => {
    Animated.timing(slideAnim, {
      toValue: BOTTOM_SHEET_HEIGHT,
      duration: 200,
      useNativeDriver: true,
    }).start(() => setSelectedVideo(null));
  };

  const handleMessage = (event: { nativeEvent: { data: string } }) => {
    try {
      const data = JSON.parse(event.nativeEvent.data);
      if (data.type === 'markerClick') {
        const video = geoVideos.find((v) => v.id === data.videoId);
        if (video) showSheet(video);
      }
    } catch {
      // ignore parse errors
    }
  };

  return (
    <SafeAreaView
      style={[
        styles.container,
        { paddingTop: Platform.OS === 'android' ? StatusBar.currentHeight : 0 },
      ]}
    >
      <StatusBar barStyle="dark-content" backgroundColor="#fff" />

      <View style={styles.header}>
        <TouchableOpacity onPress={() => router.back()}>
          <Text style={styles.backButton}>{'< Back'}</Text>
        </TouchableOpacity>
        <Text style={styles.headerTitle}>Video Locations</Text>
        <View style={{ width: 60 }} />
      </View>

      {geoVideos.length === 0 ? (
        <View style={styles.empty}>
          <Text style={styles.emptyText}>No videos with location data</Text>
          <TouchableOpacity style={styles.refreshButton} onPress={refreshVideos}>
            <Text style={styles.refreshButtonText}>Refresh</Text>
          </TouchableOpacity>
        </View>
      ) : (
        <WebView
          ref={webViewRef}
          source={{ html: buildMapHtml(geoVideos) }}
          style={styles.map}
          onMessage={handleMessage}
          javaScriptEnabled
          domStorageEnabled
          originWhitelist={['*']}
          userAgent="dev.elainedb.rn_claude/1.0"
        />
      )}

      {selectedVideo && (
        <>
          <TouchableOpacity
            style={styles.backdrop}
            activeOpacity={1}
            onPress={hideSheet}
          />
          <Animated.View
            style={[
              styles.bottomSheet,
              { transform: [{ translateY: slideAnim }] },
            ]}
          >
            <ScrollView style={styles.sheetScroll}>
              <View style={styles.sheetContent}>
                <Image
                  source={{ uri: selectedVideo.thumbnailUrl }}
                  style={styles.sheetThumbnail}
                  contentFit="cover"
                />
                <View style={styles.sheetInfo}>
                  <Text style={styles.sheetTitle} numberOfLines={2}>
                    {selectedVideo.title}
                  </Text>
                  <Text style={styles.sheetChannel}>{selectedVideo.channelName}</Text>
                  <Text style={styles.sheetDate}>
                    Published: {formatDate(selectedVideo.publishedAt)}
                  </Text>
                  {selectedVideo.recordingDate && (
                    <Text style={styles.sheetDate}>
                      Recorded: {formatDate(selectedVideo.recordingDate)}
                    </Text>
                  )}
                  {locationText(selectedVideo) && (
                    <Text style={styles.sheetLocation}>{locationText(selectedVideo)}</Text>
                  )}
                  {selectedVideo.latitude != null && selectedVideo.longitude != null && (
                    <Text style={styles.sheetCoords}>
                      GPS: {selectedVideo.latitude.toFixed(4)}, {selectedVideo.longitude.toFixed(4)}
                    </Text>
                  )}
                  {selectedVideo.tags.length > 0 && (
                    <Text style={styles.sheetTags} numberOfLines={1}>
                      Tags: {selectedVideo.tags.slice(0, 5).join(', ')}
                    </Text>
                  )}
                  <TouchableOpacity
                    style={styles.watchButton}
                    onPress={() => openVideo(selectedVideo.id)}
                  >
                    <Text style={styles.watchButtonText}>Watch on YouTube</Text>
                  </TouchableOpacity>
                </View>
              </View>
            </ScrollView>
          </Animated.View>
        </>
      )}
    </SafeAreaView>
  );
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: '#f5f5f5',
  },
  header: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'center',
    paddingHorizontal: 16,
    paddingVertical: 12,
    backgroundColor: '#fff',
    borderBottomWidth: 1,
    borderBottomColor: '#e0e0e0',
  },
  backButton: {
    fontSize: 16,
    color: '#4285F4',
    fontWeight: '500',
  },
  headerTitle: {
    fontSize: 18,
    fontWeight: '700',
    color: '#212121',
  },
  map: {
    flex: 1,
  },
  empty: {
    flex: 1,
    justifyContent: 'center',
    alignItems: 'center',
    padding: 24,
  },
  emptyText: {
    fontSize: 16,
    color: '#666',
    marginBottom: 16,
  },
  refreshButton: {
    backgroundColor: '#4285F4',
    paddingVertical: 10,
    paddingHorizontal: 24,
    borderRadius: 6,
  },
  refreshButtonText: {
    color: '#fff',
    fontSize: 14,
    fontWeight: '600',
  },
  backdrop: {
    ...StyleSheet.absoluteFillObject,
    backgroundColor: 'rgba(0,0,0,0.2)',
  },
  bottomSheet: {
    position: 'absolute',
    bottom: 0,
    left: 0,
    right: 0,
    height: BOTTOM_SHEET_HEIGHT,
    backgroundColor: '#fff',
    borderTopLeftRadius: 16,
    borderTopRightRadius: 16,
    elevation: 10,
    shadowColor: '#000',
    shadowOffset: { width: 0, height: -2 },
    shadowOpacity: 0.2,
    shadowRadius: 4,
  },
  sheetScroll: {
    flex: 1,
  },
  sheetContent: {
    flexDirection: 'row',
    padding: 12,
  },
  sheetThumbnail: {
    width: 120,
    height: 80,
    borderRadius: 8,
    backgroundColor: '#e0e0e0',
  },
  sheetInfo: {
    flex: 1,
    marginLeft: 12,
  },
  sheetTitle: {
    fontSize: 14,
    fontWeight: '600',
    color: '#212121',
  },
  sheetChannel: {
    fontSize: 12,
    color: '#666',
    marginTop: 2,
  },
  sheetDate: {
    fontSize: 11,
    color: '#888',
    marginTop: 1,
  },
  sheetLocation: {
    fontSize: 11,
    color: '#4285F4',
    marginTop: 2,
  },
  sheetCoords: {
    fontSize: 10,
    color: '#999',
    marginTop: 1,
  },
  sheetTags: {
    fontSize: 10,
    color: '#888',
    marginTop: 2,
  },
  watchButton: {
    backgroundColor: '#FF0000',
    paddingVertical: 6,
    paddingHorizontal: 12,
    borderRadius: 4,
    alignSelf: 'flex-start',
    marginTop: 6,
  },
  watchButtonText: {
    color: '#fff',
    fontSize: 12,
    fontWeight: '600',
  },
});
