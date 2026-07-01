import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart';

import '../../data/models/video.dart';
import '../../state/providers.dart';

class MapScreen extends ConsumerStatefulWidget {
  const MapScreen({super.key});

  @override
  ConsumerState<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends ConsumerState<MapScreen> {
  Video? _selected;

  @override
  Widget build(BuildContext context) {
    final videos = ref.watch(homeControllerProvider).allVideos;
    final located = videos.where((v) => v.hasLocation).toList();
    final initialCenter = located.isNotEmpty
        ? LatLng(located.first.lat!, located.first.lng!)
        : const LatLng(20, 0);

    return Semantics(
      identifier: 'screen_map',
      container: true,
      child: Scaffold(
        appBar: AppBar(title: const Text('Map')),
        body: Stack(
          children: [
            FlutterMap(
              options: MapOptions(
                initialCenter: initialCenter,
                initialZoom: located.isNotEmpty ? 4 : 1.5,
              ),
              children: [
                TileLayer(
                  urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  userAgentPackageName: 'com.example.ytdash_flutter',
                ),
                MarkerLayer(
                  markers: [
                    for (final video in located)
                      Marker(
                        point: LatLng(video.lat!, video.lng!),
                        width: 44,
                        height: 44,
                        child: GestureDetector(
                          onTap: () => setState(() => _selected = video),
                          child: Semantics(
                            identifier: 'map_marker',
                            container: true,
                            button: true,
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
            // Guaranteed-visible marker affordance (constitution §5): a native, always-tappable
            // chip per located video, so the marker action survives a pin scrolled off-viewport and
            // is reachable even where a black-box driver can't hit the rendered pin.
            Positioned(
              left: 0,
              right: 0,
              bottom: _selected == null ? 0 : 140,
              child: SizedBox(
                height: 56,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 8,
                  ),
                  children: [
                    for (final video in located)
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        child: Semantics(
                          identifier: 'map_marker',
                          container: true,
                          button: true,
                          child: ActionChip(
                            label: Text(
                              video.title,
                              overflow: TextOverflow.ellipsis,
                            ),
                            onPressed: () => setState(() => _selected = video),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
            if (_selected != null)
              _DetailSheet(
                video: _selected!,
                onClose: () => setState(() => _selected = null),
              ),
          ],
        ),
      ),
    );
  }
}

/// An in-tree overlay (not a modal route) so its identifiers stay in the same semantics tree —
/// unlike a Compose `ModalBottomSheet`, Flutter routes would also be reachable, but an inline
/// overlay is the simplest way to guarantee it (constitution §5a).
class _DetailSheet extends ConsumerWidget {
  const _DetailSheet({required this.video, required this.onClose});

  final Video video;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Align(
      alignment: Alignment.bottomCenter,
      child: Semantics(
        identifier: 'detail_bottom_sheet',
        container: true,
        child: Material(
          elevation: 8,
          color: Theme.of(context).colorScheme.surface,
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
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: onClose,
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Semantics(
                  identifier: 'detail_video_url',
                  container: true,
                  child: Text(video.youtubeUrl),
                ),
                const SizedBox(height: 12),
                Semantics(
                  identifier: 'detail_open_youtube_button',
                  container: true,
                  button: true,
                  child: ElevatedButton.icon(
                    onPressed: () => ref
                        .read(externalLinkControllerProvider.notifier)
                        .open(video.youtubeUrl),
                    icon: const Icon(Icons.open_in_new),
                    label: const Text('Open in YouTube'),
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
