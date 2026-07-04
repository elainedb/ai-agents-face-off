import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'providers.dart';
import '../domain/models.dart';
import 'home_screen.dart'; // for openExternalUrl

class MapScreen extends ConsumerStatefulWidget {
  const MapScreen({super.key});

  @override
  ConsumerState<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends ConsumerState<MapScreen> {
  @override
  Widget build(BuildContext context) {
    final state = ref.watch(videoListProvider);
    final locatedVideos = state.videos.where((v) => v.location != null).toList();

    return Semantics(
      identifier: 'screen_map',
      container: true,
      explicitChildNodes: true,
      child: Scaffold(
        appBar: AppBar(title: const Text('Map')),
        body: Stack(
          children: [
            FlutterMap(
              options: MapOptions(
                initialCenter: locatedVideos.isNotEmpty
                    ? LatLng(locatedVideos.first.location!.lat, locatedVideos.first.location!.lng)
                    : const LatLng(0, 0),
                initialZoom: 2.0,
              ),
              children: [
                TileLayer(
                  urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  userAgentPackageName: 'com.example.ytdash_flutter',
                ),
                MarkerLayer(
                  markers: locatedVideos.map((v) {
                    return Marker(
                      point: LatLng(v.location!.lat, v.location!.lng),
                      width: 40,
                      height: 40,
                      child: Semantics(
                        identifier: 'map_marker',
                        child: GestureDetector(
                          onTap: () {
                            _showBottomSheet(context, v, ref);
                          },
                          child: const Icon(Icons.location_on, color: Colors.red, size: 40),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
            // The constitution mentions a native affordance overlay fallback, just in case. 
            // We add a list of markers as a horizontal row of chips at the top.
            Positioned(
              top: 10,
              left: 0,
              right: 0,
              height: 50,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: locatedVideos.map((v) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4.0),
                    child: Semantics(
                      identifier: 'map_marker',
                      button: true,
                      child: ActionChip(
                        label: Text(v.title),
                        onPressed: () {
                          _showBottomSheet(context, v, ref);
                        },
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
            if (ref.watch(externalUrlProvider) != null)
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Semantics(
                  identifier: 'external_open_url',
                  container: true,
                  child: Container(
                    color: Colors.black54,
                    padding: const EdgeInsets.all(16),
                    child: Text(ref.watch(externalUrlProvider)!, style: const TextStyle(color: Colors.white)),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  void _showBottomSheet(BuildContext context, Video video, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      builder: (ctx) {
        return Semantics(
          identifier: 'detail_bottom_sheet',
          container: true,
          explicitChildNodes: true,
          child: Container(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(video.title, style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(height: 8),
                Semantics(
                  identifier: 'detail_video_url',
                  container: true,
                  child: Text(video.youtubeUrl),
                ),
                const SizedBox(height: 16),
                Semantics(
                  identifier: 'detail_open_youtube_button',
                  container: true,
                  button: true,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(ctx);
                      openExternalUrl(ref, video.youtubeUrl);
                    },
                    child: const Text('Open in YouTube'),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
