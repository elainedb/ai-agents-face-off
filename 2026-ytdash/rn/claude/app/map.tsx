import React, { useState } from 'react';
import { StyleSheet, View } from 'react-native';
import { useVideoStore } from '../src/state/videoStore';
import { useExternalLinkStore } from '../src/state/externalLinkStore';
import { Video } from '../src/domain/types';
import { LeafletMap } from '../src/components/LeafletMap';
import { MapMarkers } from '../src/components/MapMarkers';
import { DetailBottomSheet } from '../src/components/DetailBottomSheet';

export default function Map() {
  const videos = useVideoStore((s) => s.videos);
  const openLink = useExternalLinkStore((s) => s.open);
  const [selected, setSelected] = useState<Video | null>(null);

  const selectById = (id: string) => {
    const video = videos.find((v) => v.id === id) ?? null;
    setSelected(video);
  };

  return (
    <View testID="screen_map" style={styles.container}>
      <View style={styles.mapArea}>
        <LeafletMap videos={videos} onMarkerTap={selectById} />
      </View>
      <MapMarkers videos={videos} onSelect={setSelected} />
      {selected ? (
        <DetailBottomSheet
          video={selected}
          onOpenYoutube={(video) => openLink(video.youtubeUrl)}
          onClose={() => setSelected(null)}
        />
      ) : null}
    </View>
  );
}

const styles = StyleSheet.create({
  container: { flex: 1, backgroundColor: 'white' },
  mapArea: { flex: 1 },
});
