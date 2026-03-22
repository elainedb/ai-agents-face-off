import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:intl/intl.dart';
import 'package:latlong2/latlong.dart';

import '../../domain/entities/video.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key, required this.videos, required this.onOpenVideo});

  final List<Video> videos;
  final Future<void> Function(Video video) onOpenVideo;

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  final MapController _mapController = MapController();
  bool _didFit = false;

  @override
  Widget build(BuildContext context) {
    final videosWithCoordinates = widget.videos
        .where((video) => video.hasCoordinates)
        .toList();

    if (videosWithCoordinates.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: const Text('Video Map')),
        body: const Center(
          child: Padding(
            padding: EdgeInsets.all(24),
            child: Text('No videos with location data are available.'),
          ),
        ),
      );
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_didFit || !mounted) {
        return;
      }
      _didFit = true;
      _mapController.fitCamera(
        CameraFit.bounds(
          bounds: LatLngBounds.fromPoints(
            videosWithCoordinates
                .map((video) => LatLng(video.latitude!, video.longitude!))
                .toList(),
          ),
          padding: const EdgeInsets.all(50),
        ),
      );
    });

    return Scaffold(
      appBar: AppBar(title: const Text('Video Map')),
      body: FlutterMap(
        mapController: _mapController,
        options: MapOptions(
          initialCenter: LatLng(
            videosWithCoordinates.first.latitude!,
            videosWithCoordinates.first.longitude!,
          ),
          initialZoom: 3,
        ),
        children: <Widget>[
          TileLayer(
            urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
            userAgentPackageName: 'com.example.ytdash_flutter_codex',
          ),
          MarkerLayer(
            markers: videosWithCoordinates
                .map(
                  (video) => Marker(
                    point: LatLng(video.latitude!, video.longitude!),
                    width: 48,
                    height: 48,
                    child: GestureDetector(
                      onTap: () => _showVideoSheet(context, video),
                      child: const CircleAvatar(
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                        child: Icon(Icons.play_arrow),
                      ),
                    ),
                  ),
                )
                .toList(),
          ),
        ],
      ),
    );
  }

  Future<void> _showVideoSheet(BuildContext context, Video video) async {
    final dateFormat = DateFormat('yyyy-MM-dd');
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: false,
      builder: (context) {
        return FractionallySizedBox(
          heightFactor: 0.25,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: SizedBox(
                    width: 120,
                    child: CachedNetworkImage(
                      imageUrl: video.thumbnailUrl,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ListView(
                    children: <Widget>[
                      Row(
                        children: <Widget>[
                          Expanded(
                            child: Text(
                              video.title,
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                          ),
                          IconButton(
                            onPressed: () => Navigator.of(context).pop(),
                            icon: const Icon(Icons.close),
                          ),
                        ],
                      ),
                      Text(video.channelName),
                      Text(
                        'Published: ${dateFormat.format(video.publishedAt)}',
                      ),
                      if (video.recordingDate != null)
                        Text(
                          'Recording: ${dateFormat.format(video.recordingDate!)}',
                        ),
                      if (video.hasLocation)
                        Text('Location: ${video.locationText}'),
                      if (video.hasCoordinates)
                        Text(
                          'GPS: ${video.latitude!.toStringAsFixed(4)}, '
                          '${video.longitude!.toStringAsFixed(4)}',
                        ),
                      if (video.tags.isNotEmpty)
                        Text('Tags: ${video.tags.take(5).join(', ')}'),
                      const SizedBox(height: 8),
                      FilledButton(
                        onPressed: () => widget.onOpenVideo(video),
                        child: const Text('Watch Video'),
                      ),
                    ],
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
