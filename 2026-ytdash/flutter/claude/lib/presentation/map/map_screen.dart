import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart';

import '../../core/ui_state.dart';
import '../../domain/entities/video.dart';
import '../home/home_controller.dart';
import 'marker_detail_sheet.dart';

class MapScreen extends ConsumerStatefulWidget {
  const MapScreen({super.key});

  @override
  ConsumerState<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends ConsumerState<MapScreen> {
  Video? _selected;

  @override
  Widget build(BuildContext context) {
    final homeState = ref.watch(homeControllerProvider);
    final videosState = homeState.videos;
    final located = videosState is UiContent<List<Video>>
        ? videosState.data.where((v) => v.hasLocation).toList(growable: false)
        : const <Video>[];

    final points = located
        .map((v) => LatLng(v.lat!, v.lng!))
        .toList(growable: false);
    final cameraFit = points.isEmpty
        ? null
        : CameraFit.bounds(
            bounds: LatLngBounds.fromPoints(points),
            padding: const EdgeInsets.all(48),
          );

    return Semantics(
      container: true,
      identifier: 'screen_map',
      child: Scaffold(
        appBar: AppBar(title: const Text('Map')),
        body: Stack(
          children: [
            FlutterMap(
              options: MapOptions(
                initialCenter: points.isNotEmpty
                    ? points.first
                    : const LatLng(20, 0),
                initialZoom: points.isNotEmpty ? 4 : 2,
                initialCameraFit: cameraFit,
                onTap: (tapPosition, point) => setState(() => _selected = null),
              ),
              children: [
                TileLayer(
                  urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  userAgentPackageName: 'com.example.ytdash_flutter',
                ),
                MarkerLayer(
                  markers: [
                    for (final v in located)
                      Marker(
                        point: LatLng(v.lat!, v.lng!),
                        width: 44,
                        height: 44,
                        child: Semantics(
                          container: true,
                          identifier: 'map_marker',
                          button: true,
                          child: GestureDetector(
                            onTap: () => setState(() => _selected = v),
                            child: const Icon(
                              Icons.location_pin,
                              color: Colors.red,
                              size: 40,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ],
            ),
            // Guaranteed-visible marker affordance: survives a pin scrolling off-viewport and is
            // the deterministic tap target regardless of the map's current pan/zoom (constitution
            // §5 — the real pin above satisfies it too, since flutter_map markers are widgets, but
            // this row is kept for robustness/parity per cross-framework-setup.md).
            if (located.isNotEmpty)
              Positioned(
                left: 0,
                right: 0,
                bottom: _selected != null ? 160 : 0,
                child: Container(
                  color: Colors.black.withValues(alpha: 0.6),
                  height: 64,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    children: [
                      for (final v in located)
                        Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 10,
                          ),
                          child: Semantics(
                            container: true,
                            identifier: 'map_marker',
                            button: true,
                            child: ActionChip(
                              label: Text(
                                v.title,
                                overflow: TextOverflow.ellipsis,
                              ),
                              onPressed: () => setState(() => _selected = v),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            if (_selected != null)
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: MarkerDetailSheet(
                  video: _selected!,
                  onClose: () => setState(() => _selected = null),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
