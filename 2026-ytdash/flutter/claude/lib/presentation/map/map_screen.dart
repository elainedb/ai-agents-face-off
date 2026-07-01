import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart';

import '../../domain/models/video.dart';
import '../home/home_view_model.dart';
import 'detail_bottom_sheet.dart';

/// flutter_map is the one map engine whose markers are real widgets (constitution §5,
/// cross-framework-setup.md §C) — wrapping each marker's child in
/// `Semantics(identifier:'map_marker')` makes the rendered pin itself reachable. A "Markers" chip
/// row is rendered too, for parity/visibility when a pin scrolls off the viewport.
class MapScreen extends ConsumerWidget {
  const MapScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final located = ref
        .read(homeViewModelProvider.notifier)
        .allVideos
        .where((v) => v.hasLocation)
        .toList();
    final points = [for (final v in located) LatLng(v.lat!, v.lng!)];

    return Semantics(
      identifier: 'screen_map',
      container: true,
      child: Scaffold(
        appBar: AppBar(title: const Text('Map')),
        body: Column(
          children: [
            Expanded(
              child: FlutterMap(
                options: MapOptions(
                  initialCenter: points.isNotEmpty
                      ? points.first
                      : const LatLng(0, 0),
                  initialZoom: 1,
                  initialCameraFit: points.isNotEmpty
                      ? CameraFit.coordinates(
                          coordinates: points,
                          padding: const EdgeInsets.all(40),
                          maxZoom: 12,
                        )
                      : null,
                ),
                children: [
                  TileLayer(
                    urlTemplate:
                        'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                    userAgentPackageName: 'com.example.ytdash_flutter',
                  ),
                  MarkerLayer(
                    markers: [
                      for (final video in located)
                        Marker(
                          point: LatLng(video.lat!, video.lng!),
                          width: 44,
                          height: 44,
                          child: _MarkerPin(video: video),
                        ),
                    ],
                  ),
                ],
              ),
            ),
            if (located.isNotEmpty) _MarkerChipRow(videos: located),
          ],
        ),
      ),
    );
  }
}

void _showDetail(BuildContext context, Video video) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    builder: (_) => DetailBottomSheet(video: video),
  );
}

class _MarkerPin extends StatelessWidget {
  const _MarkerPin({required this.video});

  final Video video;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      identifier: 'map_marker',
      button: true,
      container: true,
      child: GestureDetector(
        onTap: () => _showDetail(context, video),
        child: const Icon(Icons.location_pin, color: Colors.red, size: 40),
      ),
    );
  }
}

class _MarkerChipRow extends StatelessWidget {
  const _MarkerChipRow({required this.videos});

  final List<Video> videos;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 56,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        itemCount: videos.length,
        itemBuilder: (context, index) {
          final video = videos[index];
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Semantics(
              identifier: 'map_marker',
              button: true,
              container: true,
              child: ActionChip(
                label: Text(video.title, overflow: TextOverflow.ellipsis),
                onPressed: () => _showDetail(context, video),
              ),
            ),
          );
        },
      ),
    );
  }
}
