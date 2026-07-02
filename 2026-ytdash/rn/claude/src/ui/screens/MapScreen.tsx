import React, { useMemo } from 'react';
import { Platform, Pressable, StatusBar, StyleSheet, Text, View } from 'react-native';
import { WebView } from 'react-native-webview';

import { useExternalLinkStore } from '../../state/externalLinkStore';
import { useVideoStore } from '../../state/videoStore';
import { DetailBottomSheet } from '../components/DetailBottomSheet';
import { buildLeafletHtml } from '../components/leafletHtml';
import { MapMarkers } from '../components/MapMarkers';

type Props = {
  onBack: () => void;
};

export function MapScreen({ onBack }: Props) {
  const allVideos = useVideoStore((s) => s.allVideos);
  const selectedVideoId = useVideoStore((s) => s.selectedVideoId);
  const selectMarker = useVideoStore((s) => s.selectMarker);
  const open = useExternalLinkStore((s) => s.open);

  const located = useMemo(() => allVideos.filter((v) => v.lat != null && v.lng != null), [allVideos]);
  const html = useMemo(() => buildLeafletHtml(located), [located]);
  const selected = located.find((v) => v.id === selectedVideoId) ?? null;

  return (
    <View testID="screen_map" style={styles.container}>
      <View style={styles.header}>
        <Pressable style={styles.backButton} onPress={onBack}>
          <Text style={styles.backText}>‹ Back</Text>
        </Pressable>
        <Text style={styles.title}>Map</Text>
        <View style={styles.backButton} />
      </View>
      <WebView
        originWhitelist={['*']}
        source={{ html }}
        style={styles.webview}
        onMessage={(event) => {
          const id = event.nativeEvent.data;
          if (located.some((v) => v.id === id)) selectMarker(id);
        }}
      />
      <MapMarkers videos={located} onSelect={(v) => selectMarker(v.id)} />
      {selected ? (
        <DetailBottomSheet video={selected} onOpenYoutube={(v) => open(v.youtubeUrl)} onClose={() => selectMarker(null)} />
      ) : null}
    </View>
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
    padding: 12,
    paddingTop: (Platform.OS === 'android' ? StatusBar.currentHeight ?? 24 : 0) + 12,
    borderBottomWidth: StyleSheet.hairlineWidth,
    borderBottomColor: '#ddd',
  },
  backButton: {
    minWidth: 60,
  },
  backText: {
    color: '#1a73e8',
    fontSize: 15,
  },
  title: {
    fontSize: 16,
    fontWeight: '600',
  },
  webview: {
    flex: 1,
  },
});
