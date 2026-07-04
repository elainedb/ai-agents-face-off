import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../bloc/video_bloc.dart';
import '../../domain/models/video.dart';
import '../../../../shared/external_link_manager.dart';

class MapPage extends StatelessWidget {
  const MapPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Semantics(
      identifier: 'screen_map',
      child: Scaffold(
        appBar: AppBar(title: const Text('Map')),
        body: BlocBuilder<VideoBloc, VideoState>(
          builder: (context, state) {
            if (state is VideoLoaded) {
              final locatedVideos = state.allVideos
                  .where((v) => v.lat != null && v.lng != null)
                  .toList();

              return Stack(
                children: [
                  FlutterMap(
                    options: MapOptions(
                      initialCenter: locatedVideos.isNotEmpty
                          ? LatLng(
                              locatedVideos.first.lat!,
                              locatedVideos.first.lng!,
                            )
                          : const LatLng(0, 0),
                      initialZoom: 2,
                    ),
                    children: [
                      TileLayer(
                        urlTemplate:
                            'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                        userAgentPackageName: 'com.example.ytdash_flutter',
                      ),
                      MarkerLayer(
                        markers: locatedVideos
                            .map(
                              (v) => Marker(
                                point: LatLng(v.lat!, v.lng!),
                                width: 40,
                                height: 40,
                                child: Semantics(
                                  identifier: 'map_marker',
                                  child: GestureDetector(
                                    onTap: () => _showBottomSheet(context, v),
                                    child: const Icon(
                                      Icons.location_on,
                                      color: Colors.red,
                                      size: 40,
                                    ),
                                  ),
                                ),
                              ),
                            )
                            .toList(),
                      ),
                    ],
                  ),
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: Container(
                      height: 60,
                      color: Colors.white.withOpacity(0.8),
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: locatedVideos.length,
                        itemBuilder: (context, index) {
                          final v = locatedVideos[index];
                          return Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 4.0,
                            ),
                            child: Semantics(
                              identifier: 'map_marker',
                              child: ActionChip(
                                label: Text(
                                  v.title.length > 10
                                      ? '${v.title.substring(0, 10)}...'
                                      : v.title,
                                ),
                                onPressed: () => _showBottomSheet(context, v),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ],
              );
            }
            return const Center(child: CircularProgressIndicator());
          },
        ),
      ),
    );
  }

  void _showBottomSheet(BuildContext context, Video video) {
    showModalBottomSheet(
      context: context,
      builder: (ctx) {
        return Semantics(
          identifier: 'detail_bottom_sheet',
          child: Container(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  video.title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Semantics(
                  identifier: 'detail_video_url',
                  child: Text('https://www.youtube.com/watch?v=${video.id}'),
                ),
                const SizedBox(height: 16),
                Semantics(
                  identifier: 'detail_open_youtube_button',
                  button: true,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.of(ctx).pop();
                      ExternalLinkManager.of(
                        context,
                      ).openYoutubeVideo(video.id);
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
