import React, { useEffect, useRef, useState, useCallback } from 'react';
import {
  View,
  Text,
  TouchableOpacity,
  StyleSheet,
  ActivityIndicator,
  Linking,
  Alert,
  Platform,
  StatusBar,
} from 'react-native';
import { useRouter } from 'expo-router';
import { WebView } from 'react-native-webview';
import BottomSheet, { BottomSheetView } from '@gorhom/bottom-sheet';
import { Image } from 'expo-image';
import { fetchAllVideos, VideoData } from '@/services/youtubeApi';

const MAP_HTML = `
<!DOCTYPE html>
<html>
<head>
  <meta name="viewport" content="width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no">
  <link rel="stylesheet" href="https://unpkg.com/leaflet@1.9.4/dist/leaflet.css" />
  <script src="https://unpkg.com/leaflet@1.9.4/dist/leaflet.js"></script>
  <style>
    body { margin: 0; padding: 0; }
    #map { width: 100%; height: 100vh; }
    .video-marker {
      background: #4285F4;
      border: 2px solid white;
      border-radius: 50%;
      width: 32px;
      height: 32px;
      display: flex;
      align-items: center;
      justify-content: center;
      font-size: 16px;
      box-shadow: 0 2px 6px rgba(0,0,0,0.3);
    }
  </style>
</head>
<body>
  <div id="map"></div>
  <script>
    var map = L.map('map').setView([37.7749, -122.4194], 2);
    L.tileLayer('https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png', {
      attribution: '© OpenStreetMap contributors'
    }).addTo(map);

    var markers = [];

    function addMarkers(videos) {
      var group = L.featureGroup();
      videos.forEach(function(video) {
        var icon = L.divIcon({
          className: '',
          html: '<div class="video-marker">📹</div>',
          iconSize: [32, 32],
          iconAnchor: [16, 16],
        });
        var marker = L.marker([video.latitude, video.longitude], { icon: icon })
          .addTo(map);
        marker.on('click', function() {
          var msg = JSON.stringify({ type: 'markerClick', videoId: video.id });
          if (window.ReactNativeWebView) {
            window.ReactNativeWebView.postMessage(msg);
          }
        });
        markers.push(marker);
        group.addLayer(marker);
      });
      if (markers.length > 0) {
        map.fitBounds(group.getBounds().pad(0.1));
      }
    }

    function handleMessage(event) {
      try {
        var data = typeof event.data === 'string' ? JSON.parse(event.data) : event.data;
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
  const [loading, setLoading] = useState(true);
  const [selectedVideo, setSelectedVideo] = useState<VideoData | null>(null);

  useEffect(() => {
    loadVideos();
  }, []);

  const loadVideos = async () => {
    try {
      const allVideos = await fetchAllVideos();
      const geoVideos = allVideos.filter(
        v => v.location?.latitude !== undefined && v.location?.longitude !== undefined
      );
      setVideos(geoVideos);
    } catch (e) {
      console.error('Error loading videos for map:', e);
    } finally {
      setLoading(false);
    }
  };

  const sendMarkersToWebView = () => {
    if (webViewRef.current && videos.length > 0) {
      const markerData = videos.map(v => ({
        id: v.id,
        latitude: v.location!.latitude,
        longitude: v.location!.longitude,
      }));
      setTimeout(() => {
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
        const video = videos.find(v => v.id === data.videoId);
        if (video) {
          setSelectedVideo(video);
          bottomSheetRef.current?.snapToIndex(0);
        }
      }
    } catch (e) {
      console.error('Error handling WebView message:', e);
    }
  };

  const handleWatchVideo = async () => {
    if (!selectedVideo) return;

    try {
      const urls = [
        `vnd.youtube://${selectedVideo.id}`,
        `https://www.youtube.com/watch?v=${selectedVideo.id}`,
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
        } catch {
          continue;
        }
      }

      await Linking.openURL(selectedVideo.videoUrl);
    } catch {
      Alert.alert(
        'Error',
        'Could not open video. Please make sure the YouTube app is installed.',
      );
    }
  };

  const handleSheetChanges = useCallback((index: number) => {
    if (index === -1) {
      setSelectedVideo(null);
    }
  }, []);

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
        <Text style={styles.emptyText}>No videos with location data found.</Text>
        <TouchableOpacity style={styles.refreshMapButton} onPress={loadVideos}>
          <Text style={styles.refreshMapButtonText}>Refresh</Text>
        </TouchableOpacity>
      </View>
    );
  }

  return (
    <View style={styles.container}>
      <View style={styles.header}>
        <TouchableOpacity onPress={() => router.back()}>
          <Text style={styles.backButton}>{'< Back'}</Text>
        </TouchableOpacity>
        <Text style={styles.headerTitle}>Video Locations</Text>
        <View style={styles.spacer} />
      </View>

      <WebView
        ref={webViewRef}
        source={{ html: MAP_HTML }}
        style={styles.map}
        onLoadEnd={sendMarkersToWebView}
        onMessage={handleWebViewMessage}
        javaScriptEnabled
      />

      <BottomSheet
        ref={bottomSheetRef}
        index={-1}
        snapPoints={['25%']}
        enablePanDownToClose
        onChange={handleSheetChanges}
      >
        <BottomSheetView style={styles.sheetContent}>
          {selectedVideo && (
            <>
              <View style={styles.sheetRow}>
                <Image
                  source={{ uri: selectedVideo.thumbnailUrl }}
                  style={styles.sheetThumbnail}
                />
                <View style={styles.sheetInfo}>
                  <Text style={styles.sheetTitle} numberOfLines={2}>
                    {selectedVideo.title}
                  </Text>
                  <Text style={styles.sheetChannel}>{selectedVideo.channelName}</Text>
                  <Text style={styles.sheetDate}>
                    Published: {new Date(selectedVideo.publishedAt).toLocaleDateString()}
                  </Text>
                  {selectedVideo.recordingDate && (
                    <Text style={styles.sheetDate}>
                      Recorded: {selectedVideo.recordingDate}
                    </Text>
                  )}
                </View>
              </View>

              {selectedVideo.location && (
                <Text style={styles.sheetLocation}>
                  📍 {[
                    selectedVideo.location.city,
                    selectedVideo.location.country,
                    selectedVideo.location.latitude?.toFixed(6),
                    selectedVideo.location.longitude?.toFixed(6),
                  ].filter(Boolean).join(', ')}
                </Text>
              )}

              {selectedVideo.tags.length > 0 && (
                <Text style={styles.sheetTags}>
                  {selectedVideo.tags.slice(0, 5).join(', ')}
                </Text>
              )}

              <TouchableOpacity style={styles.watchButton} onPress={handleWatchVideo}>
                <Text style={styles.watchButtonText}>Watch on YouTube</Text>
              </TouchableOpacity>
            </>
          )}
        </BottomSheetView>
      </BottomSheet>
    </View>
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
  },
  emptyContainer: {
    flex: 1,
    justifyContent: 'center',
    alignItems: 'center',
    padding: 20,
  },
  emptyText: {
    fontSize: 16,
    color: '#666',
    marginBottom: 16,
  },
  refreshMapButton: {
    backgroundColor: '#4285F4',
    paddingHorizontal: 24,
    paddingVertical: 12,
    borderRadius: 8,
  },
  refreshMapButtonText: {
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
    paddingTop: Platform.OS === 'android' ? (StatusBar.currentHeight || 0) + 12 : 12,
    backgroundColor: '#fff',
    borderBottomWidth: 1,
    borderBottomColor: '#eee',
  },
  backButton: {
    fontSize: 16,
    color: '#4285F4',
    fontWeight: '600',
  },
  headerTitle: {
    fontSize: 18,
    fontWeight: 'bold',
    color: '#333',
  },
  spacer: {
    width: 60,
  },
  map: {
    flex: 1,
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
    color: '#999',
  },
  sheetLocation: {
    fontSize: 12,
    color: '#666',
    marginBottom: 4,
  },
  sheetTags: {
    fontSize: 11,
    color: '#888',
    fontStyle: 'italic',
    marginBottom: 8,
  },
  watchButton: {
    backgroundColor: '#FF0000',
    paddingVertical: 10,
    borderRadius: 8,
    alignItems: 'center',
    marginTop: 8,
  },
  watchButtonText: {
    color: '#fff',
    fontSize: 14,
    fontWeight: '600',
  },
});
