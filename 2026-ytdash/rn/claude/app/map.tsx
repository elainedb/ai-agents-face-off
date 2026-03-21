import React, { useEffect, useRef, useState } from 'react';
import {
  View,
  Text,
  TouchableOpacity,
  StyleSheet,
  ActivityIndicator,
  Linking,
  Alert,
  Platform,
} from 'react-native';
import { useRouter } from 'expo-router';
import { WebView } from 'react-native-webview';
import { GestureHandlerRootView } from 'react-native-gesture-handler';
import BottomSheet from '@gorhom/bottom-sheet';
import { Image } from 'expo-image';
import { fetchAllVideos } from '@/services/cacheService';
import type { VideoData } from '@/services/youtubeApi';

const LEAFLET_HTML = `
<!DOCTYPE html>
<html>
<head>
  <meta name="viewport" content="width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no">
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
    var map = L.map('map').setView([37.7749, -122.4194], 2);
    L.tileLayer('https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png', {
      attribution: '&copy; OpenStreetMap contributors'
    }).addTo(map);

    var markers = [];
    var featureGroup;

    function addMarkers(videos) {
      videos.forEach(function(video) {
        var icon = L.divIcon({
          html: '<div style="background:#4285F4;color:white;border:2px solid white;border-radius:50%;width:32px;height:32px;display:flex;align-items:center;justify-content:center;font-size:16px;box-shadow:0 2px 6px rgba(0,0,0,0.3);">📷</div>',
          className: '',
          iconSize: [32, 32],
          iconAnchor: [16, 16],
        });

        var marker = L.marker([video.latitude, video.longitude], { icon: icon })
          .addTo(map);

        marker.on('click', function() {
          window.ReactNativeWebView.postMessage(JSON.stringify({
            type: 'markerClick',
            videoId: video.id
          }));
        });

        markers.push(marker);
      });

      if (markers.length > 0) {
        featureGroup = L.featureGroup(markers);
        map.fitBounds(featureGroup.getBounds().pad(0.1));
      }
    }

    function handleMessage(event) {
      try {
        var data = JSON.parse(event.data);
        if (data.type === 'addMarkers') {
          addMarkers(data.videos);
        }
      } catch(e) {}
    }

    document.addEventListener('message', handleMessage);
    window.addEventListener('message', handleMessage);
  </script>
</body>
</html>
`;

export default function MapScreen() {
  const router = useRouter();
  const webViewRef = useRef<WebView>(null);
  const bottomSheetRef = useRef<BottomSheet>(null);
  const [videos, setVideos] = useState<VideoData[]>([]);
  const [selectedVideo, setSelectedVideo] = useState<VideoData | null>(null);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    loadVideos();
  }, []);

  const loadVideos = async () => {
    try {
      const allVideos = await fetchAllVideos();
      const geoVideos = allVideos.filter(
        (v) =>
          v.location?.latitude != null && v.location?.longitude != null
      );
      setVideos(geoVideos);
    } catch (err) {
      console.error('Error loading videos for map:', err);
    } finally {
      setLoading(false);
    }
  };

  const sendMarkersToMap = () => {
    if (webViewRef.current && videos.length > 0) {
      setTimeout(() => {
        const markerData = videos.map((v) => ({
          id: v.id,
          latitude: v.location!.latitude,
          longitude: v.location!.longitude,
        }));
        webViewRef.current?.postMessage(
          JSON.stringify({ type: 'addMarkers', videos: markerData })
        );
      }, 1000);
    }
  };

  const handleWebViewMessage = (event: any) => {
    try {
      const data = JSON.parse(event.nativeEvent.data);
      if (data.type === 'markerClick') {
        const video = videos.find((v) => v.id === data.videoId);
        if (video) {
          setSelectedVideo(video);
          bottomSheetRef.current?.snapToIndex(0);
        }
      }
    } catch {}
  };

  const handleWatchVideo = async () => {
    if (!selectedVideo) return;

    const urls = [
      `vnd.youtube://${selectedVideo.id}`,
      `youtube://watch?v=${selectedVideo.id}`,
      `https://m.youtube.com/watch?v=${selectedVideo.id}`,
      selectedVideo.videoUrl,
    ];

    for (const url of urls) {
      try {
        const canOpen = await Linking.canOpenURL(url);
        if (canOpen) {
          await Linking.openURL(url);
          return;
        }
      } catch {}
    }

    Alert.alert(
      'Error',
      'Could not open video. Please install the YouTube app.'
    );
  };

  if (loading) {
    return (
      <View style={styles.loadingContainer}>
        <ActivityIndicator size="large" color="#4285F4" />
      </View>
    );
  }

  if (videos.length === 0) {
    return (
      <View style={styles.emptyContainer}>
        <Text style={styles.emptyText}>No videos with location data found</Text>
        <TouchableOpacity
          style={styles.refreshButton}
          onPress={() => {
            setLoading(true);
            loadVideos();
          }}
        >
          <Text style={styles.refreshButtonText}>Refresh</Text>
        </TouchableOpacity>
      </View>
    );
  }

  return (
    <GestureHandlerRootView style={styles.container}>
      {/* Header */}
      <View style={styles.header}>
        <TouchableOpacity onPress={() => router.back()}>
          <Text style={styles.backText}>{'< Back'}</Text>
        </TouchableOpacity>
        <Text style={styles.headerTitle}>Video Locations</Text>
        <View style={styles.spacer} />
      </View>

      {/* Map */}
      <WebView
        ref={webViewRef}
        source={{ html: LEAFLET_HTML }}
        style={styles.map}
        onLoadEnd={sendMarkersToMap}
        onMessage={handleWebViewMessage}
        javaScriptEnabled
      />

      {/* Bottom Sheet */}
      <BottomSheet
        ref={bottomSheetRef}
        index={-1}
        snapPoints={['25%']}
        enablePanDownToClose
        backgroundStyle={styles.bottomSheetBackground}
      >
        {selectedVideo && (
          <View style={styles.sheetContent}>
            <View style={styles.sheetRow}>
              <Image
                source={{ uri: selectedVideo.thumbnailUrl }}
                style={styles.sheetThumbnail}
              />
              <View style={styles.sheetInfo}>
                <Text style={styles.sheetTitle} numberOfLines={2}>
                  {selectedVideo.title}
                </Text>
                <Text style={styles.sheetChannel}>
                  {selectedVideo.channelName}
                </Text>
              </View>
            </View>

            <Text style={styles.sheetDate}>
              Published: {new Date(selectedVideo.publishedAt).toISOString().split('T')[0]}
            </Text>
            {selectedVideo.recordingDate && (
              <Text style={styles.sheetDate}>
                Recorded: {selectedVideo.recordingDate}
              </Text>
            )}
            {selectedVideo.location && (
              <Text style={styles.sheetLocation}>
                📍{' '}
                {[selectedVideo.location.city, selectedVideo.location.country]
                  .filter(Boolean)
                  .join(', ')}
                {selectedVideo.location.latitude != null &&
                  ` (${selectedVideo.location.latitude.toFixed(6)}, ${selectedVideo.location.longitude!.toFixed(6)})`}
              </Text>
            )}
            {selectedVideo.tags.length > 0 && (
              <Text style={styles.sheetTags}>
                {selectedVideo.tags.slice(0, 5).join(', ')}
              </Text>
            )}

            <TouchableOpacity
              style={styles.watchButton}
              onPress={handleWatchVideo}
            >
              <Text style={styles.watchButtonText}>Watch on YouTube</Text>
            </TouchableOpacity>
          </View>
        )}
      </BottomSheet>
    </GestureHandlerRootView>
  );
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: '#fff',
  },
  loadingContainer: {
    flex: 1,
    justifyContent: 'center',
    alignItems: 'center',
    backgroundColor: '#fff',
  },
  emptyContainer: {
    flex: 1,
    justifyContent: 'center',
    alignItems: 'center',
    backgroundColor: '#fff',
    padding: 40,
  },
  emptyText: {
    fontSize: 16,
    color: '#888',
    textAlign: 'center',
    marginBottom: 16,
  },
  refreshButton: {
    backgroundColor: '#4285F4',
    paddingHorizontal: 20,
    paddingVertical: 10,
    borderRadius: 8,
  },
  refreshButtonText: {
    color: '#fff',
    fontSize: 14,
    fontWeight: '600',
  },
  header: {
    flexDirection: 'row',
    alignItems: 'center',
    justifyContent: 'space-between',
    paddingHorizontal: 16,
    paddingVertical: 12,
    paddingTop: Platform.OS === 'android' ? 40 : 50,
    backgroundColor: '#fff',
    borderBottomWidth: 1,
    borderBottomColor: '#eee',
  },
  backText: {
    fontSize: 16,
    color: '#4285F4',
    fontWeight: '500',
  },
  headerTitle: {
    fontSize: 18,
    fontWeight: 'bold',
    color: '#333',
  },
  spacer: {
    width: 50,
  },
  map: {
    flex: 1,
  },
  bottomSheetBackground: {
    backgroundColor: '#fff',
    borderRadius: 16,
    shadowColor: '#000',
    shadowOffset: { width: 0, height: -2 },
    shadowOpacity: 0.1,
    shadowRadius: 8,
    elevation: 8,
  },
  sheetContent: {
    padding: 16,
  },
  sheetRow: {
    flexDirection: 'row',
    marginBottom: 8,
  },
  sheetThumbnail: {
    width: 80,
    height: 60,
    borderRadius: 6,
    backgroundColor: '#ddd',
  },
  sheetInfo: {
    flex: 1,
    marginLeft: 12,
  },
  sheetTitle: {
    fontSize: 14,
    fontWeight: '600',
    color: '#333',
  },
  sheetChannel: {
    fontSize: 12,
    color: '#666',
    marginTop: 2,
  },
  sheetDate: {
    fontSize: 11,
    color: '#888',
  },
  sheetLocation: {
    fontSize: 11,
    color: '#555',
    marginTop: 2,
  },
  sheetTags: {
    fontSize: 10,
    color: '#999',
    fontStyle: 'italic',
    marginTop: 2,
  },
  watchButton: {
    backgroundColor: '#FF0000',
    paddingVertical: 10,
    borderRadius: 8,
    alignItems: 'center',
    marginTop: 10,
  },
  watchButtonText: {
    color: '#fff',
    fontSize: 14,
    fontWeight: '600',
  },
});
