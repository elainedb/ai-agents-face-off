import { useEffect, useState, useRef, useCallback } from 'react';
import {
  View,
  Text,
  TouchableOpacity,
  StyleSheet,
  ActivityIndicator,
  Linking,
  Alert,
} from 'react-native';
import { useRouter } from 'expo-router';
import WebView from 'react-native-webview';
import { GestureHandlerRootView } from 'react-native-gesture-handler';
import BottomSheet, { BottomSheetView } from '@gorhom/bottom-sheet';
import { Image } from 'expo-image';
import { fetchAllVideos, VideoData } from '@/services/youtubeApi';

export default function MapScreen() {
  const router = useRouter();
  const webViewRef = useRef<WebView>(null);
  const bottomSheetRef = useRef<BottomSheet>(null);
  const [videos, setVideos] = useState<VideoData[]>([]);
  const [selectedVideo, setSelectedVideo] = useState<VideoData | null>(null);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    const load = async () => {
      try {
        const allVideos = await fetchAllVideos();
        const geoVideos = allVideos.filter(
          (v) =>
            v.location?.latitude !== undefined &&
            v.location?.longitude !== undefined
        );
        setVideos(geoVideos);
      } catch (e) {
        console.error('Error loading videos for map:', e);
      } finally {
        setLoading(false);
      }
    };
    load();
  }, []);

  const handleMessage = useCallback(
    (event: any) => {
      try {
        const data = JSON.parse(event.nativeEvent.data);
        if (data.type === 'markerClick') {
          const video = videos.find((v) => v.id === data.videoId);
          if (video) {
            setSelectedVideo(video);
            bottomSheetRef.current?.snapToIndex(0);
          }
        }
      } catch (e) {
        console.log('Message parse error:', e);
      }
    },
    [videos]
  );

  const sendMarkersToWebView = useCallback(() => {
    if (!webViewRef.current || videos.length === 0) return;

    const markers = videos.map((v) => ({
      id: v.id,
      title: v.title,
      lat: v.location!.latitude,
      lon: v.location!.longitude,
    }));

    setTimeout(() => {
      webViewRef.current?.postMessage(JSON.stringify({ type: 'addMarkers', markers }));
    }, 1000);
  }, [videos]);

  const handleWatchVideo = async () => {
    if (!selectedVideo) return;
    const videoId = selectedVideo.id;

    try {
      const url = `vnd.youtube://${videoId}`;
      const canOpen = await Linking.canOpenURL(url);
      if (canOpen) {
        await Linking.openURL(url);
        return;
      }
    } catch {}

    try {
      const altUrl = `https://m.youtube.com/watch?v=${videoId}`;
      await Linking.openURL(altUrl);
    } catch {
      try {
        await Linking.openURL(selectedVideo.videoUrl);
      } catch {
        Alert.alert(
          'Cannot open video',
          'Please install the YouTube app or try again later.'
        );
      }
    }
  };

  const mapHtml = `
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

    function handleMessage(event) {
      try {
        var data = typeof event.data === 'string' ? JSON.parse(event.data) : event.data;
        if (data.type === 'addMarkers') {
          var featureGroup = L.featureGroup();
          data.markers.forEach(function(m) {
            var icon = L.divIcon({
              className: '',
              html: '<div class="video-marker">📹</div>',
              iconSize: [32, 32],
              iconAnchor: [16, 16]
            });
            var marker = L.marker([m.lat, m.lon], { icon: icon });
            marker.on('click', function() {
              window.ReactNativeWebView.postMessage(JSON.stringify({
                type: 'markerClick',
                videoId: m.id
              }));
            });
            marker.addTo(map);
            featureGroup.addLayer(marker);
          });
          if (data.markers.length > 0) {
            map.fitBounds(featureGroup.getBounds().pad(0.1));
          }
        }
      } catch(e) {
        console.log('Error handling message:', e);
      }
    }

    document.addEventListener('message', handleMessage);
    window.addEventListener('message', handleMessage);
  </script>
</body>
</html>`;

  if (loading) {
    return (
      <View style={styles.loadingContainer}>
        <ActivityIndicator size="large" color="#4285F4" />
        <Text style={styles.loadingText}>Loading map...</Text>
      </View>
    );
  }

  if (videos.length === 0) {
    return (
      <View style={styles.emptyContainer}>
        <Text style={styles.emptyText}>No videos with location data found</Text>
        <TouchableOpacity
          style={styles.refreshButton}
          onPress={() => router.back()}
        >
          <Text style={styles.refreshButtonText}>Go Back</Text>
        </TouchableOpacity>
      </View>
    );
  }

  return (
    <GestureHandlerRootView style={styles.container}>
      <View style={styles.header}>
        <TouchableOpacity onPress={() => router.back()}>
          <Text style={styles.backButton}>{'< Back'}</Text>
        </TouchableOpacity>
        <Text style={styles.headerTitle}>Video Locations</Text>
        <View style={styles.spacer} />
      </View>

      <WebView
        ref={webViewRef}
        source={{ html: mapHtml }}
        style={styles.map}
        onLoadEnd={sendMarkersToWebView}
        onMessage={handleMessage}
        javaScriptEnabled
      />

      <BottomSheet
        ref={bottomSheetRef}
        snapPoints={['25%']}
        index={-1}
        enablePanDownToClose
      >
        <BottomSheetView style={styles.sheetContent}>
          {selectedVideo && (
            <>
              <View style={styles.videoDetail}>
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
                  <Text style={styles.sheetDate}>
                    {new Date(selectedVideo.publishedAt).toISOString().split('T')[0]}
                  </Text>
                  {selectedVideo.recordingDate && (
                    <Text style={styles.sheetDate}>
                      Recorded: {selectedVideo.recordingDate}
                    </Text>
                  )}
                  {selectedVideo.location && (
                    <Text style={styles.sheetLocation}>
                      📍{' '}
                      {[
                        selectedVideo.location.city,
                        selectedVideo.location.country,
                      ]
                        .filter(Boolean)
                        .join(', ')}
                      {selectedVideo.location.latitude !== undefined &&
                        ` (${selectedVideo.location.latitude.toFixed(6)}, ${selectedVideo.location.longitude!.toFixed(6)})`}
                    </Text>
                  )}
                  {selectedVideo.tags && selectedVideo.tags.length > 0 && (
                    <Text style={styles.sheetTags} numberOfLines={1}>
                      {selectedVideo.tags.slice(0, 5).join(', ')}
                    </Text>
                  )}
                </View>
              </View>
              <TouchableOpacity
                style={styles.watchButton}
                onPress={handleWatchVideo}
              >
                <Text style={styles.watchButtonText}>Watch on YouTube</Text>
              </TouchableOpacity>
            </>
          )}
        </BottomSheetView>
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
  loadingText: {
    marginTop: 12,
    fontSize: 16,
    color: '#666',
  },
  emptyContainer: {
    flex: 1,
    justifyContent: 'center',
    alignItems: 'center',
    padding: 20,
    backgroundColor: '#fff',
  },
  emptyText: {
    fontSize: 16,
    color: '#666',
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
    fontWeight: '600',
  },
  header: {
    flexDirection: 'row',
    alignItems: 'center',
    justifyContent: 'space-between',
    paddingHorizontal: 16,
    paddingVertical: 12,
    backgroundColor: '#fff',
    borderBottomWidth: 1,
    borderBottomColor: '#eee',
    paddingTop: 40,
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
    paddingHorizontal: 16,
    paddingBottom: 16,
  },
  videoDetail: {
    flexDirection: 'row',
    marginBottom: 12,
  },
  sheetThumbnail: {
    width: 80,
    height: 60,
    borderRadius: 4,
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
    paddingVertical: 12,
    borderRadius: 8,
    alignItems: 'center',
  },
  watchButtonText: {
    color: '#fff',
    fontSize: 15,
    fontWeight: '600',
  },
});
