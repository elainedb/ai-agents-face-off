import React, { useEffect, useState, useRef, useCallback } from 'react';
import {
  View,
  Text,
  TouchableOpacity,
  StyleSheet,
  ActivityIndicator,
  Image,
  Linking,
  Alert,
} from 'react-native';
import { useRouter } from 'expo-router';
import { WebView } from 'react-native-webview';
import { GestureHandlerRootView } from 'react-native-gesture-handler';
import BottomSheet, { BottomSheetView } from '@gorhom/bottom-sheet';
import { fetchAllVideos, type VideoData } from '@/services/youtubeApi';

const generateMapHTML = () => `
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
      attribution: '&copy; OpenStreetMap contributors'
    }).addTo(map);

    var markers = [];
    var featureGroup;

    function addMarkers(videos) {
      videos.forEach(function(video) {
        var icon = L.divIcon({
          className: '',
          html: '<div class="video-marker">🎥</div>',
          iconSize: [32, 32],
          iconAnchor: [16, 16]
        });
        var marker = L.marker([video.lat, video.lng], { icon: icon }).addTo(map);
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
    const loadVideos = async () => {
      try {
        const allVideos = await fetchAllVideos();
        const geoVideos = allVideos.filter(
          v => v.location?.latitude !== undefined && v.location?.longitude !== undefined
        );
        setVideos(geoVideos);
      } catch (error) {
        console.error('Error loading videos for map:', error);
      } finally {
        setLoading(false);
      }
    };
    loadVideos();
  }, []);

  const sendMarkersToWebView = useCallback(() => {
    if (webViewRef.current && videos.length > 0) {
      const markerData = videos.map(v => ({
        id: v.id,
        lat: v.location!.latitude,
        lng: v.location!.longitude,
      }));
      setTimeout(() => {
        webViewRef.current?.postMessage(
          JSON.stringify({ type: 'addMarkers', videos: markerData })
        );
      }, 1000);
    }
  }, [videos]);

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
      console.warn('Error handling WebView message:', e);
    }
  };

  const handleWatchOnYouTube = async () => {
    if (!selectedVideo) return;
    const videoId = selectedVideo.id;

    try {
      const deepLink = `vnd.youtube://${videoId}`;
      const canOpen = await Linking.canOpenURL(deepLink);
      if (canOpen) {
        await Linking.openURL(deepLink);
        return;
      }
    } catch {}

    try {
      await Linking.openURL(`https://m.youtube.com/watch?v=${videoId}`);
      return;
    } catch {}

    try {
      await Linking.openURL(selectedVideo.videoUrl);
    } catch {
      Alert.alert(
        'Cannot open video',
        'Please install the YouTube app or try again later.'
      );
    }
  };

  const handleRefresh = async () => {
    setLoading(true);
    try {
      const allVideos = await fetchAllVideos(true);
      const geoVideos = allVideos.filter(
        v => v.location?.latitude !== undefined && v.location?.longitude !== undefined
      );
      setVideos(geoVideos);
    } catch (error) {
      console.error('Error refreshing:', error);
    } finally {
      setLoading(false);
    }
  };

  if (loading) {
    return (
      <View style={styles.loadingContainer}>
        <ActivityIndicator size="large" color="#4285F4" />
        <Text style={styles.loadingText}>Loading map data...</Text>
      </View>
    );
  }

  if (videos.length === 0) {
    return (
      <View style={styles.emptyContainer}>
        <Text style={styles.emptyText}>No videos with location data found.</Text>
        <TouchableOpacity style={styles.refreshButton} onPress={handleRefresh}>
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
          <Text style={styles.backButton}>{'< Back'}</Text>
        </TouchableOpacity>
        <Text style={styles.headerTitle}>Video Locations</Text>
        <View style={styles.headerSpacer} />
      </View>

      {/* Map */}
      <WebView
        ref={webViewRef}
        source={{ html: generateMapHTML() }}
        style={styles.map}
        onLoad={sendMarkersToWebView}
        onMessage={handleWebViewMessage}
        javaScriptEnabled
      />

      {/* Bottom Sheet */}
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
                  style={styles.detailThumbnail}
                />
                <View style={styles.detailInfo}>
                  <Text style={styles.detailTitle} numberOfLines={2}>
                    {selectedVideo.title}
                  </Text>
                  <Text style={styles.detailChannel}>
                    {selectedVideo.channelName}
                  </Text>
                  <Text style={styles.detailDate}>
                    {new Date(selectedVideo.publishedAt).toLocaleDateString()}
                  </Text>
                  {selectedVideo.recordingDate && (
                    <Text style={styles.detailDate}>
                      Recorded: {selectedVideo.recordingDate}
                    </Text>
                  )}
                  {selectedVideo.location && (
                    <Text style={styles.detailLocation}>
                      📍{' '}
                      {[selectedVideo.location.city, selectedVideo.location.country]
                        .filter(Boolean)
                        .join(', ')}
                      {selectedVideo.location.latitude !== undefined &&
                        ` (${selectedVideo.location.latitude.toFixed(6)}, ${selectedVideo.location.longitude!.toFixed(6)})`}
                    </Text>
                  )}
                  {selectedVideo.tags.length > 0 && (
                    <Text style={styles.detailTags}>
                      {selectedVideo.tags.slice(0, 5).join(', ')}
                    </Text>
                  )}
                </View>
              </View>
              <TouchableOpacity
                style={styles.watchButton}
                onPress={handleWatchOnYouTube}
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
  },
  loadingText: {
    marginTop: 12,
    color: '#666',
  },
  emptyContainer: {
    flex: 1,
    justifyContent: 'center',
    alignItems: 'center',
    padding: 40,
  },
  emptyText: {
    fontSize: 16,
    color: '#666',
    textAlign: 'center',
    marginBottom: 16,
  },
  refreshButton: {
    backgroundColor: '#4285F4',
    paddingHorizontal: 24,
    paddingVertical: 12,
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
  },
  headerSpacer: {
    width: 60,
  },
  map: {
    flex: 1,
  },
  sheetContent: {
    padding: 16,
  },
  videoDetail: {
    flexDirection: 'row',
  },
  detailThumbnail: {
    width: 80,
    height: 60,
    borderRadius: 4,
  },
  detailInfo: {
    flex: 1,
    marginLeft: 12,
  },
  detailTitle: {
    fontSize: 14,
    fontWeight: '600',
  },
  detailChannel: {
    fontSize: 12,
    color: '#666',
    marginTop: 2,
  },
  detailDate: {
    fontSize: 11,
    color: '#888',
    marginTop: 1,
  },
  detailLocation: {
    fontSize: 11,
    color: '#555',
    marginTop: 2,
  },
  detailTags: {
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
    marginTop: 12,
  },
  watchButtonText: {
    color: '#fff',
    fontWeight: '600',
    fontSize: 15,
  },
});
