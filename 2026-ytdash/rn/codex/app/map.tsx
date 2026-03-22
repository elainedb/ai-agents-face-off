import { useEffect, useMemo, useRef, useState } from 'react';
import { Alert, Image, Linking, StyleSheet, Text, TouchableOpacity, View } from 'react-native';
import BottomSheet, { BottomSheetView } from '@gorhom/bottom-sheet';
import { useRouter } from 'expo-router';
import { WebView } from 'react-native-webview';

import { fetchAllVideos, type VideoData } from '@/services/youtubeApi';

const initialLatitude = 37.7749;
const initialLongitude = -122.4194;

function buildMapHtml() {
  return `<!DOCTYPE html>
  <html>
    <head>
      <meta charset="utf-8" />
      <meta name="viewport" content="width=device-width, initial-scale=1.0, maximum-scale=1.0" />
      <link
        rel="stylesheet"
        href="https://unpkg.com/leaflet@1.9.4/dist/leaflet.css"
        integrity="sha256-p4NxAoJBhIIN+hmNHrzRCf9tD/miZyoHS5obTRR9BMY="
        crossorigin=""
      />
      <style>
        html, body, #map { height: 100%; margin: 0; padding: 0; }
        .video-marker {
          align-items: center;
          background: #4285F4;
          border: 2px solid #fff;
          border-radius: 18px;
          box-shadow: 0 6px 12px rgba(0,0,0,.25);
          color: #fff;
          display: flex;
          font-size: 18px;
          height: 36px;
          justify-content: center;
          width: 36px;
        }
      </style>
    </head>
    <body>
      <div id="map"></div>
      <script src="https://unpkg.com/leaflet@1.9.4/dist/leaflet.js" integrity="sha256-20nQCchB9co0qIjJZRGuk2/Z9VM+kNiyxNV1lvTlZBo=" crossorigin=""></script>
      <script>
        const map = L.map('map').setView([${initialLatitude}, ${initialLongitude}], 2);
        const markers = L.featureGroup().addTo(map);

        L.tileLayer('https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png', {
          attribution: '&copy; OpenStreetMap contributors'
        }).addTo(map);

        function handleMessage(event) {
          try {
            const payload = JSON.parse(event.data);
            if (payload.type !== 'markers') {
              return;
            }

            markers.clearLayers();
            payload.videos.forEach((video) => {
              const icon = L.divIcon({
                className: '',
                html: '<div class="video-marker">📹</div>',
                iconSize: [36, 36],
                iconAnchor: [18, 18]
              });

              const marker = L.marker([video.location.latitude, video.location.longitude], { icon }).addTo(markers);
              marker.on('click', () => {
                window.ReactNativeWebView.postMessage(JSON.stringify({
                  type: 'markerClick',
                  videoId: video.id
                }));
              });
            });

            if (markers.getLayers().length > 0) {
              map.fitBounds(markers.getBounds().pad(0.1));
            }
          } catch (error) {
            console.error(error);
          }
        }

        document.addEventListener('message', handleMessage);
        window.addEventListener('message', handleMessage);
      </script>
    </body>
  </html>`;
}

async function openYoutubeVideo(video: VideoData) {
  const urls = [
    `vnd.youtube://${video.id}`,
    `vnd.youtube://www.youtube.com/watch?v=${video.id}`,
    `https://m.youtube.com/watch?v=${video.id}`,
    video.videoUrl,
  ];

  for (const url of urls) {
    const supported = await Linking.canOpenURL(url).catch(() => url.startsWith('https://'));
    if (supported) {
      await Linking.openURL(url);
      return;
    }
  }

  Alert.alert('Unable to open video', 'Install the YouTube app or open the video in a browser.');
}

export default function MapScreen() {
  const router = useRouter();
  const webViewRef = useRef<WebView>(null);
  const bottomSheetRef = useRef<BottomSheet>(null);
  const [videos, setVideos] = useState<VideoData[]>([]);
  const [selectedVideo, setSelectedVideo] = useState<VideoData | null>(null);
  const [message, setMessage] = useState('Loading map data...');

  const reloadVideos = async () => {
    setMessage('Loading map data...');

    try {
      const loadedVideos = await fetchAllVideos(true);
      setVideos(loadedVideos);
      if (loadedVideos.length === 0) {
        setMessage('No videos with location data found');
      }
    } catch (error) {
      console.log('Failed to refresh videos', error);
      setMessage('No videos with location data found');
    }
  };

  const mappableVideos = useMemo(
    () =>
      videos.filter(
        (video) =>
          typeof video.location?.latitude === 'number' && typeof video.location?.longitude === 'number'
      ),
    [videos]
  );

  useEffect(() => {
    fetchAllVideos()
      .then((loadedVideos) => {
        setVideos(loadedVideos);
        if (loadedVideos.length === 0) {
          setMessage('No videos found.');
        }
      })
      .catch((loadError) => {
        console.log('Failed to load map videos', loadError);
        setMessage('No videos with location data found');
      });
  }, []);

  useEffect(() => {
    if (mappableVideos.length === 0) {
      setMessage('No videos with location data found');
      return;
    }

    const timer = setTimeout(() => {
      webViewRef.current?.postMessage(
        JSON.stringify({
          type: 'markers',
          videos: mappableVideos,
        })
      );
    }, 1000);

    return () => clearTimeout(timer);
  }, [mappableVideos]);

  const handleMessage = (event: { nativeEvent: { data: string } }) => {
    try {
      const payload = JSON.parse(event.nativeEvent.data) as { type?: string; videoId?: string };
      if (payload.type !== 'markerClick' || !payload.videoId) {
        return;
      }

      const matchedVideo = mappableVideos.find((video) => video.id === payload.videoId) ?? null;
      setSelectedVideo(matchedVideo);
      bottomSheetRef.current?.snapToIndex(0);
    } catch (error) {
      console.log('Invalid WebView message', error);
    }
  };

  return (
    <View style={styles.container}>
      <View style={styles.header}>
        <TouchableOpacity onPress={() => router.back()} style={styles.backButton}>
          <Text style={styles.backText}>{'< Back'}</Text>
        </TouchableOpacity>
        <Text style={styles.headerTitle}>Video Locations</Text>
        <View style={styles.headerSpacer} />
      </View>

      {mappableVideos.length === 0 ? (
        <View style={styles.emptyState}>
          <Text style={styles.emptyTitle}>{message}</Text>
          <TouchableOpacity onPress={() => void reloadVideos()} style={styles.refreshButton}>
            <Text style={styles.refreshText}>Refresh Videos</Text>
          </TouchableOpacity>
        </View>
      ) : (
        <>
          <WebView
            ref={webViewRef}
            originWhitelist={['*']}
            onMessage={handleMessage}
            source={{ html: buildMapHtml() }}
            style={styles.webView}
          />

          <BottomSheet
            enablePanDownToClose
            index={-1}
            onClose={() => setSelectedVideo(null)}
            ref={bottomSheetRef}
            snapPoints={['25%']}>
            <BottomSheetView style={styles.sheetContent}>
              {selectedVideo ? (
                <>
                  <Image source={{ uri: selectedVideo.thumbnailUrl }} style={styles.sheetThumbnail} />
                  <Text style={styles.sheetTitle} numberOfLines={2}>
                    {selectedVideo.title}
                  </Text>
                  <Text style={styles.sheetMeta}>{selectedVideo.channelName}</Text>
                  <Text style={styles.sheetMeta}>Published: {selectedVideo.publishedAt.slice(0, 10)}</Text>
                  {selectedVideo.recordingDate ? (
                    <Text style={styles.sheetMeta}>Recorded: {selectedVideo.recordingDate}</Text>
                  ) : null}
                  {selectedVideo.location ? (
                    <Text style={styles.sheetMeta}>
                      📍 {selectedVideo.location.city ? `${selectedVideo.location.city}, ` : ''}
                      {selectedVideo.location.country ?? 'Unknown'} (
                      {selectedVideo.location.latitude?.toFixed(6)}, {selectedVideo.location.longitude?.toFixed(6)})
                    </Text>
                  ) : null}
                  {selectedVideo.tags.length > 0 ? (
                    <Text style={styles.sheetMeta}>Tags: {selectedVideo.tags.slice(0, 5).join(', ')}</Text>
                  ) : null}
                  <TouchableOpacity
                    onPress={() => void openYoutubeVideo(selectedVideo)}
                    style={styles.watchButton}>
                    <Text style={styles.watchText}>Watch on YouTube</Text>
                  </TouchableOpacity>
                </>
              ) : (
                <Text style={styles.sheetMeta}>Tap a marker to see video details.</Text>
              )}
            </BottomSheetView>
          </BottomSheet>
        </>
      )}
    </View>
  );
}

const styles = StyleSheet.create({
  container: {
    backgroundColor: '#ffffff',
    flex: 1,
  },
  header: {
    alignItems: 'center',
    flexDirection: 'row',
    justifyContent: 'space-between',
    paddingHorizontal: 16,
    paddingVertical: 18,
  },
  backButton: {
    minWidth: 72,
  },
  backText: {
    color: '#1d4ed8',
    fontSize: 16,
    fontWeight: '600',
  },
  headerTitle: {
    color: '#111827',
    fontSize: 20,
    fontWeight: '700',
  },
  headerSpacer: {
    minWidth: 72,
  },
  webView: {
    flex: 1,
  },
  emptyState: {
    alignItems: 'center',
    flex: 1,
    justifyContent: 'center',
    padding: 24,
  },
  emptyTitle: {
    color: '#111827',
    fontSize: 18,
    fontWeight: '700',
    marginBottom: 16,
    textAlign: 'center',
  },
  refreshButton: {
    backgroundColor: '#1d4ed8',
    borderRadius: 10,
    paddingHorizontal: 18,
    paddingVertical: 12,
  },
  refreshText: {
    color: '#ffffff',
    fontWeight: '600',
  },
  sheetContent: {
    flex: 1,
    gap: 8,
    padding: 16,
  },
  sheetTitle: {
    color: '#111827',
    fontSize: 18,
    fontWeight: '700',
  },
  sheetThumbnail: {
    alignSelf: 'flex-start',
    borderRadius: 12,
    height: 60,
    width: 80,
  },
  sheetMeta: {
    color: '#4b5563',
    fontSize: 14,
  },
  watchButton: {
    alignItems: 'center',
    backgroundColor: '#FF0000',
    borderRadius: 10,
    marginTop: 12,
    paddingVertical: 12,
  },
  watchText: {
    color: '#ffffff',
    fontWeight: '700',
  },
});
