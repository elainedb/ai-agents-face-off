import { useEffect, useRef, useState } from 'react';
import {
  View,
  Text,
  StyleSheet,
  TouchableOpacity,
  SafeAreaView,
  Platform,
  StatusBar,
  Animated,
  Linking,
  Alert,
  Dimensions,
} from 'react-native';
import { WebView } from 'react-native-webview';
import { Image } from 'expo-image';
import { router } from 'expo-router';
import { useVideosStore } from '@/src/features/videos/presentation/stores/videos-store';
import { Video, hasCoordinates, locationText } from '@/src/features/videos/domain/entities/video';

function formatDate(date: Date): string {
  return date.toISOString().split('T')[0];
}

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

export default function MapScreen() {
  const { allVideos, refreshVideos } = useVideosStore();
  const webViewRef = useRef<WebView>(null);
  const [selectedVideo, setSelectedVideo] = useState<Video | null>(null);
  const [mapReady, setMapReady] = useState(false);
  const slideAnim = useRef(new Animated.Value(0)).current;

  const videosWithCoords = allVideos.filter(hasCoordinates);

  useEffect(() => {
    if (selectedVideo) {
      Animated.spring(slideAnim, {
        toValue: 1,
        useNativeDriver: true,
      }).start();
    } else {
      Animated.timing(slideAnim, {
        toValue: 0,
        duration: 200,
        useNativeDriver: true,
      }).start();
    }
  }, [selectedVideo]);

  useEffect(() => {
    if (mapReady && webViewRef.current && videosWithCoords.length > 0) {
      const markersJs = videosWithCoords
        .map(
          (v) =>
            `addMarker(${v.latitude}, ${v.longitude}, ${JSON.stringify(v.id)}, ${JSON.stringify(v.title)});`,
        )
        .join('\n');
      const boundsJs = `fitAllMarkers();`;
      webViewRef.current.injectJavaScript(`${markersJs}\n${boundsJs}\ntrue;`);
    }
  }, [mapReady, videosWithCoords.length]);

  const handleMessage = (event: { nativeEvent: { data: string } }) => {
    try {
      const data = JSON.parse(event.nativeEvent.data);
      if (data.type === 'markerClick') {
        const video = allVideos.find((v) => v.id === data.videoId);
        if (video) setSelectedVideo(video);
      } else if (data.type === 'mapReady') {
        setMapReady(true);
      }
    } catch {
      // ignore parse errors
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
      attribution: '&copy; OpenStreetMap contributors'
    }).addTo(map);

    var markers = [];

    function addMarker(lat, lng, videoId, title) {
      var marker = L.marker([lat, lng]).addTo(map);
      marker.bindPopup(title);
      marker.on('click', function() {
        window.ReactNativeWebView.postMessage(JSON.stringify({
          type: 'markerClick',
          videoId: videoId
        }));
      });
      markers.push(marker);
    }

    function fitAllMarkers() {
      if (markers.length > 0) {
        var group = L.featureGroup(markers);
        map.fitBounds(group.getBounds(), { padding: [30, 30] });
      }
    }

    map.whenReady(function() {
      window.ReactNativeWebView.postMessage(JSON.stringify({ type: 'mapReady' }));
    });
  </script>
</body>
</html>
  `;

  const panelTranslateY = slideAnim.interpolate({
    inputRange: [0, 1],
    outputRange: [400, 0],
  });

  if (videosWithCoords.length === 0) {
    return (
      <SafeAreaView style={styles.container}>
        <View style={styles.header}>
          <TouchableOpacity onPress={() => router.back()}>
            <Text style={styles.backButton}>{'< Back'}</Text>
          </TouchableOpacity>
          <Text style={styles.headerTitle}>Video Locations</Text>
          <View style={{ width: 60 }} />
        </View>
        <View style={styles.centered}>
          <Text style={styles.emptyText}>No videos with location data.</Text>
          <TouchableOpacity style={styles.refreshBtn} onPress={refreshVideos}>
            <Text style={styles.refreshBtnText}>Refresh</Text>
          </TouchableOpacity>
        </View>
      </SafeAreaView>
    );
  }

  return (
    <SafeAreaView style={styles.container}>
      <View style={styles.header}>
        <TouchableOpacity onPress={() => router.back()}>
          <Text style={styles.backButton}>{'< Back'}</Text>
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
      />

      {selectedVideo && (
        <>
          <TouchableOpacity
            style={styles.backdrop}
            activeOpacity={1}
            onPress={() => setSelectedVideo(null)}
          />
          <Animated.View
            style={[
              styles.panel,
              { transform: [{ translateY: panelTranslateY }] },
            ]}
          >
            <View style={styles.panelHeader}>
              <Text style={styles.panelTitle} numberOfLines={2}>
                {selectedVideo.title}
              </Text>
              <TouchableOpacity onPress={() => setSelectedVideo(null)}>
                <Text style={styles.closeBtn}>X</Text>
              </TouchableOpacity>
            </View>
            <Image
              source={{ uri: selectedVideo.thumbnailUrl }}
              style={styles.panelThumb}
              contentFit="cover"
            />
            <Text style={styles.panelChannel}>{selectedVideo.channelName}</Text>
            <Text style={styles.panelDate}>
              Published: {formatDate(selectedVideo.publishedAt)}
            </Text>
            {selectedVideo.recordingDate && (
              <Text style={styles.panelDate}>
                Recorded: {formatDate(selectedVideo.recordingDate)}
              </Text>
            )}
            {locationText(selectedVideo) && (
              <Text style={styles.panelLocation}>{locationText(selectedVideo)}</Text>
            )}
            {hasCoordinates(selectedVideo) && (
              <Text style={styles.panelCoords}>
                GPS: {selectedVideo.latitude!.toFixed(4)}, {selectedVideo.longitude!.toFixed(4)}
              </Text>
            )}
            {selectedVideo.tags.length > 0 && (
              <View style={styles.panelTags}>
                {selectedVideo.tags.slice(0, 5).map((tag, i) => (
                  <View key={i} style={styles.panelTag}>
                    <Text style={styles.panelTagText}>{tag}</Text>
                  </View>
                ))}
              </View>
            )}
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

const { height: SCREEN_HEIGHT } = Dimensions.get('window');

const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: '#fff',
    paddingTop: Platform.OS === 'android' ? StatusBar.currentHeight : 0,
  },
  header: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'center',
    paddingHorizontal: 16,
    paddingVertical: 12,
    backgroundColor: '#fff',
    borderBottomWidth: 1,
    borderBottomColor: '#eee',
    zIndex: 10,
  },
  backButton: {
    fontSize: 16,
    color: '#4285F4',
    fontWeight: '600',
  },
  headerTitle: {
    fontSize: 18,
    fontWeight: '700',
    color: '#333',
  },
  webview: {
    flex: 1,
  },
  centered: {
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
  refreshBtn: {
    backgroundColor: '#4285F4',
    paddingHorizontal: 24,
    paddingVertical: 10,
    borderRadius: 6,
  },
  refreshBtnText: {
    color: '#fff',
    fontSize: 14,
    fontWeight: '600',
  },
  backdrop: {
    position: 'absolute',
    top: 0,
    left: 0,
    right: 0,
    bottom: 0,
    backgroundColor: 'rgba(0,0,0,0.3)',
  },
  panel: {
    position: 'absolute',
    bottom: 0,
    left: 0,
    right: 0,
    backgroundColor: '#fff',
    borderTopLeftRadius: 16,
    borderTopRightRadius: 16,
    padding: 16,
    maxHeight: SCREEN_HEIGHT * 0.6,
    elevation: 8,
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
    flex: 1,
    fontSize: 16,
    fontWeight: '600',
    color: '#333',
    marginRight: 8,
  },
  closeBtn: {
    fontSize: 18,
    color: '#999',
    fontWeight: '700',
    padding: 4,
  },
  panelThumb: {
    width: '100%',
    height: 160,
    borderRadius: 8,
    marginBottom: 8,
  },
  panelChannel: {
    fontSize: 14,
    color: '#666',
    marginBottom: 4,
  },
  panelDate: {
    fontSize: 12,
    color: '#888',
    marginBottom: 2,
  },
  panelLocation: {
    fontSize: 12,
    color: '#4285F4',
    marginTop: 4,
  },
  panelCoords: {
    fontSize: 11,
    color: '#999',
    marginTop: 2,
  },
  panelTags: {
    flexDirection: 'row',
    flexWrap: 'wrap',
    marginTop: 8,
    gap: 4,
  },
  panelTag: {
    backgroundColor: '#e8f0fe',
    paddingHorizontal: 8,
    paddingVertical: 2,
    borderRadius: 12,
  },
  panelTagText: {
    fontSize: 11,
    color: '#4285F4',
  },
  watchButton: {
    backgroundColor: '#FF0000',
    paddingVertical: 12,
    borderRadius: 8,
    alignItems: 'center',
    marginTop: 12,
  },
  watchButtonText: {
    color: '#fff',
    fontSize: 16,
    fontWeight: '600',
  },
});
