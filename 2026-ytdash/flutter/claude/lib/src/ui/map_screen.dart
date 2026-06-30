import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart';

import '../domain/video.dart';
import '../state/providers.dart';
import 'identified.dart';

/// Iteration 4 — OpenStreetMap map with a marker per located video.
///
/// Per constitution §5 / cross-framework-setup §C, the harness-reachable
/// `map_marker` lives on a native, accessible affordance (the chip strip),
/// since map-rendered pins may not be reachable by a black-box tool. flutter_map
/// markers are real widgets so we tag them too, but the always-visible chips are
/// the guaranteed harness path. `map_marker_fallback_used=false`.
class MapScreen extends ConsumerStatefulWidget {
  const MapScreen({super.key});

  @override
  ConsumerState<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends ConsumerState<MapScreen> {
  Video? _selected;

  void _select(Video v) => setState(() => _selected = v);
  void _close() => setState(() => _selected = null);

  @override
  Widget build(BuildContext context) {
    final located = ref.watch(videosControllerProvider.select((s) => s.located));

    return IdentifiedScope(
      'screen_map',
      child: Scaffold(
        appBar: AppBar(title: const Text('Map')),
        body: Stack(
          children: [
            Column(
              children: [
                // Guaranteed-visible, accessible marker affordance (harness path).
                _markerStrip(located),
                Expanded(child: _map(located)),
              ],
            ),
            if (_selected != null) _detailSheet(_selected!),
          ],
        ),
      ),
    );
  }

  Widget _markerStrip(List<Video> located) {
    if (located.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(16),
        child: Text('No located videos.'),
      );
    }
    return Container(
      width: double.infinity,
      color: Theme.of(context).colorScheme.surfaceContainerHighest,
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 8),
        child: Row(
          children: [
            for (final v in located)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: Identified(
                  'map_marker',
                  button: true,
                  label: v.title,
                  onTap: () => _select(v),
                  child: ActionChip(
                    avatar: const Icon(Icons.location_on, size: 18),
                    label: Text(
                      v.title,
                      overflow: TextOverflow.ellipsis,
                    ),
                    onPressed: () => _select(v),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _map(List<Video> located) {
    final center = located.isNotEmpty
        ? LatLng(located.first.lat!, located.first.lng!)
        : const LatLng(20, 0);
    return FlutterMap(
      options: MapOptions(
        initialCenter: center,
        initialZoom: located.isNotEmpty ? 3 : 1,
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
                child: Identified(
                  'map_marker',
                  button: true,
                  label: v.title,
                  onTap: () => _select(v),
                  child: GestureDetector(
                    onTap: () => _select(v),
                    child: const Icon(Icons.location_on,
                        color: Colors.red, size: 40),
                  ),
                ),
              ),
          ],
        ),
      ],
    );
  }

  Widget _detailSheet(Video v) {
    return Align(
      alignment: Alignment.bottomCenter,
      child: IdentifiedScope(
        'detail_bottom_sheet',
        child: Material(
          elevation: 12,
          color: Theme.of(context).colorScheme.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
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
                          v.title,
                          style: const TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: _close,
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(v.description),
                  const SizedBox(height: 12),
                  Identified(
                    'detail_video_url',
                    label: v.youtubeUrl,
                    child: Text(
                      v.youtubeUrl,
                      style: const TextStyle(color: Colors.blue),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Identified(
                    'detail_open_youtube_button',
                    button: true,
                    label: 'Open in YouTube',
                    onTap: () => ref
                        .read(externalLinkControllerProvider.notifier)
                        .open(v.youtubeUrl),
                    child: ElevatedButton.icon(
                      icon: const Icon(Icons.open_in_new),
                      label: const Text('Open in YouTube'),
                      onPressed: () => ref
                          .read(externalLinkControllerProvider.notifier)
                          .open(v.youtubeUrl),
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
