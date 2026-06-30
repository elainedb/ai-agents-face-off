import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';

import '../data/models/video.dart';
import 'app_state.dart';
import 'home_view_model.dart';
import 'widgets/test_id.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  Video? _selected;

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<HomeViewModel>();
    // The map plots every located video, independent of any active list filter.
    final markers = vm.allVideos.where((v) => v.hasLocation).toList();

    final center = markers.isNotEmpty
        ? LatLng(markers.first.lat!, markers.first.lng!)
        : const LatLng(20, 0);

    return IdNode(
      'screen_map',
      child: Scaffold(
        appBar: AppBar(title: const Text('Map')),
        body: Stack(
          children: [
            FlutterMap(
              options: MapOptions(
                initialCenter: center,
                initialZoom: markers.isNotEmpty ? 3 : 1,
              ),
              children: [
                TileLayer(
                  urlTemplate:
                      'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  userAgentPackageName: 'com.example.ytdash_flutter',
                ),
                MarkerLayer(
                  markers: [
                    for (final v in markers)
                      Marker(
                        point: LatLng(v.lat!, v.lng!),
                        width: 44,
                        height: 44,
                        child: IdNode(
                          'map_marker',
                          button: true,
                          child: GestureDetector(
                            onTap: () => setState(() => _selected = v),
                            child: const Icon(Icons.location_on,
                                color: Colors.red, size: 40),
                          ),
                        ),
                      ),
                  ],
                ),
              ],
            ),
            // Guaranteed-visible accessible marker affordance (constitution §5):
            // one tappable chip per located video, always reachable by Maestro
            // even if a pin scrolls off-viewport.
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: _markerChips(context, markers),
            ),
            if (_selected != null) _detailSheet(context, _selected!),
          ],
        ),
      ),
    );
  }

  Widget _markerChips(BuildContext context, List<Video> markers) {
    return Material(
      color: Colors.white,
      elevation: 8,
      child: SizedBox(
        height: 64,
        child: ListView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
          children: [
            for (final v in markers)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: IdNode(
                  'map_marker',
                  button: true,
                  child: ActionChip(
                    avatar: const Icon(Icons.location_on, size: 18),
                    label: Text(v.title, overflow: TextOverflow.ellipsis),
                    onPressed: () => setState(() => _selected = v),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _detailSheet(BuildContext context, Video video) {
    return Align(
      alignment: Alignment.bottomCenter,
      child: IdNode(
        'detail_bottom_sheet',
        child: Material(
          elevation: 16,
          color: Colors.white,
          child: SafeArea(
            top: false,
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
                          video.title,
                          style: const TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => setState(() => _selected = null),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(video.description),
                  const SizedBox(height: 12),
                  // The exact watch URL of the selected video (AC-MAP-03 copies
                  // this and compares it to what gets opened).
                  IdText(
                    'detail_video_url',
                    text: video.youtubeUrl,
                    child: Text(
                      video.youtubeUrl,
                      style: const TextStyle(fontSize: 13, color: Colors.blue),
                    ),
                  ),
                  const SizedBox(height: 12),
                  IdNode(
                    'detail_open_youtube_button',
                    button: true,
                    child: ElevatedButton.icon(
                      onPressed: () =>
                          context.read<AppState>().openExternal(video.youtubeUrl),
                      icon: const Icon(Icons.open_in_new),
                      label: const Text('Open in YouTube'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
