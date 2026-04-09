import { useRef, useState, useEffect } from 'react';
import {
  View,
  Text,
  StyleSheet,
  TouchableOpacity,
  SafeAreaView,
  Animated,
  Dimensions,
  Platform,
  StatusBar,
  Linking,
  Alert,
  ActivityIndicator,
} from 'react-native';
import { WebView } from 'react-native-webview';
import { Image } from 'expo-image';
import { router } from 'expo-router';
import { useVideosStore } from '@/src/features/videos/presentation/stores/videos-store';
import { Video, hasCoordinates, locationText } from '@/src/features/videos/domain/entities/video';

const { height: SCREEN_HEIGHT } = Dimensions.get('window');
const PANEL_HEIGHT = 320;

const openVideo = async (videoId: string) => {
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
};

function formatDate(date: Date): string {
  return date.toISOString().split('T')[0];
}

export default function MapScreen() {
  const { allVideos, refreshVideos } = useVideosStore();
  const webViewRef = useRef<WebView>(null);
  const [selectedVideo, setSelectedVideo] = useState<Video | null>(null);
  const [mapReady, setMapReady] = useState(false);
  const panelAnim = useRef(new Animated.Value(PANEL_HEIGHT)).current;

  const videosWithCoords = allVideos.filter(hasCoordinates);

  const showPanel = (video: Video) => {
    setSelectedVideo(video);
    Animated.spring(panelAnim, {
      toValue: 0,
      useNativeDriver: true,
    }).start();
  };

  const hidePanel = () => {
    Animated.timing(panelAnim, {
      toValue: PANEL_HEIGHT,
      duration: 200,
      useNativeDriver: true,
    }).start(() => setSelectedVideo(null));
  };

  useEffect(() => {
    if (mapReady && videosWithCoords.length > 0 && webViewRef.current) {
      const markers = videosWithCoords.map((v) => ({
        id: v.id,
        lat: v.latitude!,
        lng: v.longitude!,
        title: v.title,
        channel: v.channelName,
      }));
      const js = `window.__setMarkers(${JSON.stringify(markers)}); true;`;
      webViewRef.current.injectJavaScript(js);
    }
  }, [mapReady, videosWithCoords]);

  const handleMessage = (event: { nativeEvent: { data: string } }) => {
    try {
      const data = JSON.parse(event.nativeEvent.data);
      if (data.type === 'mapReady') {
        setMapReady(true);
      } else if (data.type === 'markerClick') {
        const video = allVideos.find((v) => v.id === data.videoId);
        if (video) showPanel(video);
      }
    } catch {
      // ignore
    }
  };

  const mapHtml = `
    <!DOCTYPE html>
    <html>
    <head>
      <meta name="viewport" content="width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no" />
      <link rel="stylesheet" href="https://unpkg.com/leaflet@1.9.4/dist/leaflet.css" />
      <script src="https://unpkg.com/leaflet@1.9.4/dist/leaflet.js"></script>
      <style>
        body { margin: 0; padding: 0; }
        #map { width: 100%; height: 100vh; }
      </style>
    </head>
    <body>
      <div id="map"></div>
      <script>
        var map = L.map('map').setView([20, 0], 2);
        L.tileLayer('https://tile.openstreetmap.org/{z}/{x}/{y}.png', {
          maxZoom: 19,
          attribution: '&copy; OpenStreetMap'
        }).addTo(map);

        var markers = [];

        window.__setMarkers = function(data) {
          markers.forEach(function(m) { map.removeLayer(m); });
          markers = [];
          var bounds = [];
          data.forEach(function(item) {
            var marker = L.marker([item.lat, item.lng])
              .addTo(map)
              .bindPopup(item.title);
            marker.on('click', function() {
              window.ReactNativeWebView.postMessage(JSON.stringify({
                type: 'markerClick',
                videoId: item.id
              }));
            });
            markers.push(marker);
            bounds.push([item.lat, item.lng]);
          });
          if (bounds.length > 0) {
            map.fitBounds(bounds, { padding: [50, 50] });
          }
        };

        window.ReactNativeWebView.postMessage(JSON.stringify({ type: 'mapReady' }));
      </script>
    </body>
    </html>
  `;

  if (videosWithCoords.length === 0) {
    return (
      <SafeAreaView
        style={[
          styles.container,
          { paddingTop: Platform.OS === 'android' ? StatusBar.currentHeight ?? 0 : 0 },
        ]}
      >
        <View style={styles.header}>
          <TouchableOpacity onPress={() => router.back()}>
            <Text style={styles.backText}>{'< Back'}</Text>
          </TouchableOpacity>
          <Text style={styles.headerTitle}>Video Locations</Text>
          <View style={{ width: 60 }} />
        </View>
        <View style={styles.centered}>
          <Text style={styles.emptyText}>No videos with location data available.</Text>
          <TouchableOpacity style={styles.refreshButton} onPress={refreshVideos}>
            <Text style={styles.refreshButtonText}>Refresh</Text>
          </TouchableOpacity>
        </View>
      </SafeAreaView>
    );
  }

  return (
    <SafeAreaView
      style={[
        styles.container,
        { paddingTop: Platform.OS === 'android' ? StatusBar.currentHeight ?? 0 : 0 },
      ]}
    >
      <View style={styles.header}>
        <TouchableOpacity onPress={() => router.back()}>
          <Text style={styles.backText}>{'< Back'}</Text>
        </TouchableOpacity>
        <Text style={styles.headerTitle}>Video Locations</Text>
        <View style={{ width: 60 }} />
      </View>

      <WebView
        ref={webViewRef}
        source={{ html: mapHtml }}
        style={styles.webview}
        onMessage={handleMessage}
        applicationNameForUserAgent="dev.elainedb.rn_claude/1.0"
        javaScriptEnabled
        domStorageEnabled
      />

      {selectedVideo && (
        <>
          <TouchableOpacity
            style={styles.backdrop}
            activeOpacity={1}
            onPress={hidePanel}
          />
          <Animated.View
            style={[
              styles.panel,
              { transform: [{ translateY: panelAnim }] },
            ]}
          >
            <View style={styles.panelHeader}>
              <Text style={styles.panelTitle} numberOfLines={2}>
                {selectedVideo.title}
              </Text>
              <TouchableOpacity onPress={hidePanel}>
                <Text style={styles.closeText}>X</Text>
              </TouchableOpacity>
            </View>
            <View style={styles.panelContent}>
              <Image
                source={{ uri: selectedVideo.thumbnailUrl }}
                style={styles.panelThumb}
                contentFit="cover"
              />
              <View style={styles.panelInfo}>
                <Text style={styles.panelChannel}>{selectedVideo.channelName}</Text>
                <Text style={styles.panelDate}>
                  Published: {formatDate(selectedVideo.publishedAt)}
                </Text>
                {selectedVideo.recordingDate && (
                  <Text style={styles.panelDate}>
                    Recorded: {formatDate(selectedVideo.recordingDate)}
                  </Text>
                )}
                {(selectedVideo.city || selectedVideo.country) && (
                  <Text style={styles.panelLocation}>{locationText(selectedVideo)}</Text>
                )}
                {hasCoordinates(selectedVideo) && (
                  <Text style={styles.panelCoords}>
                    GPS: {selectedVideo.latitude!.toFixed(4)}, {selectedVideo.longitude!.toFixed(4)}
                  </Text>
                )}
                {selectedVideo.tags.length > 0 && (
                  <Text style={styles.panelTags} numberOfLines={1}>
                    Tags: {selectedVideo.tags.slice(0, 5).join(', ')}
                  </Text>
                )}
              </View>
            </View>
            <TouchableOpacity
              style={styles.watchButton}
              onPress={() => openVideo(selectedVideo.id)}
            >
              <Text style={styles.watchButtonText}>Watch on YouTube</Text>
            </TouchableOpacity>
          </Animated.View>
        </>
      )}
    </SafeAreaView>
  );
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: '#fff',
  },
  header: {
    flexDirection: 'row',
    alignItems: 'center',
    justifyContent: 'space-between',
    paddingHorizontal: 16,
    paddingVertical: 12,
    backgroundColor: '#fff',
    borderBottomWidth: 1,
    borderBottomColor: '#e0e0e0',
    zIndex: 10,
  },
  backText: {
    fontSize: 16,
    color: '#4285F4',
    fontWeight: '500',
  },
  headerTitle: {
    fontSize: 18,
    fontWeight: '600',
    color: '#212121',
  },
  webview: {
    flex: 1,
  },
  centered: {
    flex: 1,
    justifyContent: 'center',
    alignItems: 'center',
    padding: 32,
  },
  emptyText: {
    fontSize: 16,
    color: '#757575',
    textAlign: 'center',
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
    backgroundColor: 'rgba(0,0,0,0.3)',
    zIndex: 20,
  },
  panel: {
    position: 'absolute',
    bottom: 0,
    left: 0,
    right: 0,
    height: PANEL_HEIGHT,
    backgroundColor: '#fff',
    borderTopLeftRadius: 16,
    borderTopRightRadius: 16,
    padding: 16,
    zIndex: 30,
    elevation: 10,
    shadowColor: '#000',
    shadowOffset: { width: 0, height: -2 },
    shadowOpacity: 0.25,
    shadowRadius: 4,
  },
  panelHeader: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'flex-start',
    marginBottom: 8,
  },
  panelTitle: {
    fontSize: 16,
    fontWeight: '600',
    color: '#212121',
    flex: 1,
    marginRight: 12,
  },
  closeText: {
    fontSize: 18,
    color: '#757575',
    fontWeight: '700',
  },
  panelContent: {
    flexDirection: 'row',
    flex: 1,
  },
  panelThumb: {
    width: 120,
    height: 80,
    borderRadius: 8,
    backgroundColor: '#e0e0e0',
  },
  panelInfo: {
    flex: 1,
    marginLeft: 12,
  },
  panelChannel: {
    fontSize: 14,
    color: '#616161',
    marginBottom: 2,
  },
  panelDate: {
    fontSize: 12,
    color: '#757575',
  },
  panelLocation: {
    fontSize: 12,
    color: '#4285F4',
    marginTop: 2,
  },
  panelCoords: {
    fontSize: 11,
    color: '#9e9e9e',
  },
  panelTags: {
    fontSize: 11,
    color: '#757575',
    marginTop: 4,
  },
  watchButton: {
    backgroundColor: '#FF0000',
    paddingVertical: 12,
    borderRadius: 8,
    alignItems: 'center',
    marginTop: 8,
  },
  watchButtonText: {
    color: '#fff',
    fontSize: 16,
    fontWeight: '600',
  },
});
