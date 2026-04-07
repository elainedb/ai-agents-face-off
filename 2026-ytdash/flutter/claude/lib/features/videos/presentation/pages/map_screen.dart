import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:intl/intl.dart';
import 'package:latlong2/latlong.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:ytdash_flutter_claude/features/videos/domain/entities/video.dart';
import 'package:ytdash_flutter_claude/features/videos/presentation/bloc/videos_bloc.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  final MapController _mapController = MapController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Video Map')),
      body: BlocBuilder<VideosBloc, VideosState>(
        builder: (context, state) {
          return state.when(
            initial: () =>
                const Center(child: CircularProgressIndicator()),
            loading: () =>
                const Center(child: CircularProgressIndicator()),
            error: (message) => Center(child: Text(message)),
            loaded: (videos, filteredVideos, a, b, c, d, e) {
              final geoVideos = filteredVideos
                  .where((v) => v.hasCoordinates)
                  .toList();

              if (geoVideos.isEmpty) {
                return const Center(
                  child: Text('No videos with location data available.'),
                );
              }

              return _buildMap(geoVideos);
            },
          );
        },
      ),
    );
  }

  Widget _buildMap(List<Video> videos) {
    final bounds = LatLngBounds.fromPoints(
      videos.map((v) => LatLng(v.latitude!, v.longitude!)).toList(),
    );

    return FlutterMap(
      mapController: _mapController,
      options: MapOptions(
        initialCameraFit: CameraFit.bounds(
          bounds: bounds,
          padding: const EdgeInsets.all(50),
        ),
      ),
      children: [
        TileLayer(
          urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
          userAgentPackageName: 'dev.elainedb.ytdash_flutter_claude',
        ),
        MarkerLayer(
          markers: videos.map((video) {
            return Marker(
              point: LatLng(video.latitude!, video.longitude!),
              width: 40,
              height: 40,
              child: GestureDetector(
                onTap: () => _showVideoBottomSheet(context, video),
                child: Container(
                  decoration: const BoxDecoration(
                    color: Colors.red,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.play_arrow,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  void _showVideoBottomSheet(BuildContext context, Video video) {
    final dateFormat = DateFormat('yyyy-MM-dd');

    showModalBottomSheet(
      context: context,
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.25,
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Close button row
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              Expanded(
                child: SingleChildScrollView(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Thumbnail
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: CachedNetworkImage(
                          imageUrl: video.thumbnailUrl,
                          width: 120,
                          height: 68,
                          fit: BoxFit.cover,
                        ),
                      ),
                      const SizedBox(width: 12),
                      // Info
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              video.title,
                              style: Theme.of(context)
                                  .textTheme
                                  .titleSmall,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            Text(video.channelName),
                            Text(
                                'Published: ${dateFormat.format(video.publishedAt)}'),
                            if (video.hasRecordingDate)
                              Text(
                                  'Recorded: ${dateFormat.format(video.recordingDate!)}'),
                            if (video.hasLocation)
                              Text('Location: ${video.locationText}'),
                            if (video.hasCoordinates)
                              Text(
                                'GPS: ${video.latitude!.toStringAsFixed(4)}, ${video.longitude!.toStringAsFixed(4)}',
                                style: Theme.of(context)
                                    .textTheme
                                    .bodySmall,
                              ),
                            if (video.tags.isNotEmpty)
                              Wrap(
                                spacing: 4,
                                children: video.tags
                                    .take(3)
                                    .map((t) => Chip(
                                          label: Text(t,
                                              style: const TextStyle(
                                                  fontSize: 10)),
                                          materialTapTargetSize:
                                              MaterialTapTargetSize
                                                  .shrinkWrap,
                                          visualDensity:
                                              VisualDensity.compact,
                                        ))
                                    .toList(),
                              ),
                            const SizedBox(height: 4),
                            ElevatedButton.icon(
                              onPressed: () => _launchVideo(video.id),
                              icon: const Icon(Icons.play_arrow),
                              label: const Text('Watch Video'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.red,
                                foregroundColor: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _launchVideo(String videoId) async {
    final deepLink = Uri.parse('youtube://watch?v=$videoId');
    if (await canLaunchUrl(deepLink)) {
      await launchUrl(deepLink);
      return;
    }
    final browserUrl =
        Uri.parse('https://www.youtube.com/watch?v=$videoId');
    await launchUrl(browserUrl, mode: LaunchMode.externalApplication);
  }
}
