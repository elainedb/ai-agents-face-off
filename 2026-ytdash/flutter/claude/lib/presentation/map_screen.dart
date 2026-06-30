import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';

import '../data/models/video.dart';
import 'external_open_controller.dart';
import 'video_controller.dart';
import 'widgets/test_id.dart';

/// Iteration 4 — OpenStreetMap map with a marker per located video.
///
/// Per constitution §5 / cross-framework-setup §C, the harness-reachable affordance is a native,
/// accessible element (the `map_marker` chip row), rendered FIRST so `map_marker` index 0 is
/// deterministic. flutter_map markers are real widgets, so we additionally tag the rendered pins —
/// but the chips are the guaranteed path (survive tiles failing / a pin scrolling off-viewport).
class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  Video? _selected;

  void _select(Video v) => setState(() => _selected = v);

  @override
  Widget build(BuildContext context) {
    final vc = context.watch<VideoController>();
    final located = vc.locatedVideos;
    final center = located.isNotEmpty
        ? LatLng(located.first.lat!, located.first.lng!)
        : const LatLng(20, 0);

    return TestId(
      'screen_map',
      container: true,
      child: Scaffold(
        appBar: AppBar(title: const Text('Map')),
        body: Column(
          children: [
            // Accessible marker affordance — one chip per located video (constitution §5).
            SizedBox(
              height: 56,
              child: located.isEmpty
                  ? const Center(child: Text('Loading map markers…'))
                  : ListView(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      children: [
                        for (final v in located)
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
                            child: TestId(
                              'map_marker',
                              button: true,
                              child: ActionChip(
                                avatar: const Icon(Icons.location_on, size: 18),
                                label: Text(v.title, overflow: TextOverflow.ellipsis),
                                onPressed: () => _select(v),
                              ),
                            ),
                          ),
                      ],
                    ),
            ),
            Expanded(
              child: Stack(
                children: [
                  FlutterMap(
                    options: MapOptions(
                      initialCenter: center,
                      initialZoom: located.isEmpty ? 1 : 3,
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
                              child: TestId(
                                'map_marker',
                                button: true,
                                child: GestureDetector(
                                  onTap: () => _select(v),
                                  child: const Icon(Icons.location_pin,
                                      color: Colors.red, size: 40),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ],
                  ),
                  if (_selected != null) _detailSheet(context, _selected!),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _detailSheet(BuildContext context, Video v) {
    return Align(
      alignment: Alignment.bottomCenter,
      child: TestId(
        'detail_bottom_sheet',
        container: true,
        child: Material(
          elevation: 8,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        v.title,
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => setState(() => _selected = null),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(v.description, maxLines: 2, overflow: TextOverflow.ellipsis),
                const SizedBox(height: 8),
                // Text is EXACTLY the watch URL so AC-MAP-03 can copy it and compare to
                // external_open_url after opening.
                TestId(
                  'detail_video_url',
                  child: Text(v.youtubeUrl, style: const TextStyle(color: Colors.blue)),
                ),
                const SizedBox(height: 12),
                TestId(
                  'detail_open_youtube_button',
                  button: true,
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.open_in_new),
                    label: const Text('Open in YouTube'),
                    onPressed: () => context.read<ExternalOpenController>().open(v.youtubeUrl),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
