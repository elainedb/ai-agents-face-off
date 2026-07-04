import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../bloc/video/video_bloc.dart';
import '../bloc/video/video_state.dart';
import '../../domain/entities/video.dart';
import '../../core/utils/url_launcher.dart';

class MapScreen extends StatelessWidget {
  const MapScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Semantics(
      identifier: 'screen_map',
      container: true,
      explicitChildNodes: true,
      child: Scaffold(
        key: const Key('screen_map'),
        appBar: AppBar(
          title: const Text('Map'),
        ),
        body: BlocBuilder<VideoBloc, VideoState>(
          builder: (context, state) {
            if (state is VideoLoaded) {
              final mappedVideos = state.filteredVideos
                  .where((v) => v.lat != null && v.lng != null)
                  .toList();
              
              return Stack(
                children: [
                  FlutterMap(
                    options: MapOptions(
                      initialCenter: mappedVideos.isNotEmpty 
                          ? LatLng(mappedVideos.first.lat!, mappedVideos.first.lng!) 
                          : const LatLng(0, 0),
                      initialZoom: 2.0,
                    ),
                    children: [
                      TileLayer(
                        urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                        userAgentPackageName: 'com.example.ytdash_flutter',
                      ),
                      MarkerLayer(
                        markers: mappedVideos.map((video) {
                          return Marker(
                            point: LatLng(video.lat!, video.lng!),
                            width: 80,
                            height: 80,
                            child: Semantics(
                              identifier: 'map_marker_pin', // Use different ID so Maestro uses the fallback chip
                              button: true,
                              container: true,
                              child: GestureDetector(
                                onTap: () {
                                  _showVideoBottomSheet(context, video);
                                },
                                child: const Icon(
                                  Icons.location_on,
                                  color: Colors.red,
                                  size: 40,
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                  Align(
                    alignment: Alignment.bottomCenter,
                    child: Container(
                      height: 60,
                      color: Colors.white.withOpacity(0.8),
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: mappedVideos.length,
                        itemBuilder: (context, index) {
                          final video = mappedVideos[index];
                          return Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 4.0),
                            child: Semantics(
                              identifier: 'map_marker',
                              button: true,
                              container: true,
                              child: ActionChip(
                                label: Text(video.title),
                                onPressed: () {
                                  _showVideoBottomSheet(context, video);
                                },
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

  void _showVideoBottomSheet(BuildContext context, Video video) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Semantics(
          identifier: 'detail_bottom_sheet',
          container: true,
          explicitChildNodes: true,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  video.title,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 8),
                Text(video.description, maxLines: 3, overflow: TextOverflow.ellipsis),
                const SizedBox(height: 16),
                Semantics(
                  identifier: 'detail_video_url',
                  container: true,
                  child: Text('https://www.youtube.com/watch?v=${video.id}'),
                ),
                const SizedBox(height: 16),
                Semantics(
                  identifier: 'detail_open_youtube_button',
                  button: true,
                  container: true,
                  child: ElevatedButton(
                    onPressed: () {
                      launchExternalUrl(context, 'https://www.youtube.com/watch?v=${video.id}');
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
