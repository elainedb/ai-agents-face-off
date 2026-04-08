import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:intl/intl.dart';
import 'package:latlong2/latlong.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../domain/entities/video.dart';

class MapScreen extends StatelessWidget {
  const MapScreen({super.key, required this.videos});

  final List<Video> videos;

  @override
  Widget build(BuildContext context) {
    final locatedVideos = videos.where((video) => video.hasCoordinates).toList();
    if (locatedVideos.isEmpty) {
      return const Scaffold(
        body: Center(
          child: Padding(
            padding: EdgeInsets.all(24),
            child: Text('No videos with location data are available.'),
          ),
        ),
      );
    }

    final initialCenter = _computeCenter(locatedVideos);
    final initialZoom = _computeZoom(locatedVideos);

    return Scaffold(
      appBar: AppBar(title: const Text('Video Map')),
      body: FlutterMap(
        options: MapOptions(
          initialCenter: initialCenter,
          initialZoom: initialZoom,
        ),
        children: <Widget>[
          TileLayer(
            urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
            userAgentPackageName: 'dev.elainedb.ytdash_flutter_codex',
          ),
          MarkerLayer(
            markers: locatedVideos.map((video) {
              return Marker(
                point: LatLng(video.latitude!, video.longitude!),
                width: 48,
                height: 48,
                child: GestureDetector(
                  onTap: () => _showVideoSheet(context, video),
                  child: Container(
                    decoration: const BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.play_arrow, color: Colors.white),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  LatLng _computeCenter(List<Video> videos) {
    final latitudes = videos.map((video) => video.latitude!).toList();
    final longitudes = videos.map((video) => video.longitude!).toList();
    final centerLat = (latitudes.reduce((a, b) => a + b)) / latitudes.length;
    final centerLng = (longitudes.reduce((a, b) => a + b)) / longitudes.length;
    return LatLng(centerLat, centerLng);
  }

  double _computeZoom(List<Video> videos) {
    final latitudes = videos.map((video) => video.latitude!).toList();
    final longitudes = videos.map((video) => video.longitude!).toList();
    final latSpread = latitudes.reduce((a, b) => a > b ? a : b) -
        latitudes.reduce((a, b) => a < b ? a : b);
    final lngSpread = longitudes.reduce((a, b) => a > b ? a : b) -
        longitudes.reduce((a, b) => a < b ? a : b);
    final spread = latSpread > lngSpread ? latSpread : lngSpread;
    if (spread < 0.05) return 11;
    if (spread < 0.2) return 9;
    if (spread < 1) return 7;
    if (spread < 5) return 5;
    return 3;
  }

  void _showVideoSheet(BuildContext context, Video video) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: false,
      builder: (context) {
        return FractionallySizedBox(
          heightFactor: 0.25,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Row(
                  children: <Widget>[
                    Expanded(
                      child: Text(video.title, style: Theme.of(context).textTheme.titleMedium),
                    ),
                    IconButton(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(Icons.close),
                    ),
                  ],
                ),
                Expanded(
                  child: Row(
                    children: <Widget>[
                      if (video.thumbnailUrl.isNotEmpty)
                        ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.network(
                            video.thumbnailUrl,
                            width: 120,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return const SizedBox(
                                width: 120,
                                child: Center(child: Icon(Icons.broken_image_outlined)),
                              );
                            },
                          ),
                        ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: SingleChildScrollView(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Text(video.channelName),
                              Text('Published: ${DateFormat('yyyy-MM-dd').format(video.publishedAt)}'),
                              if (video.recordingDate != null)
                                Text(
                                  'Recording: ${DateFormat('yyyy-MM-dd').format(video.recordingDate!)}',
                                ),
                              if (video.hasLocation) Text(video.locationText),
                              if (video.hasCoordinates)
                                Text(
                                  '${video.latitude!.toStringAsFixed(4)}, '
                                  '${video.longitude!.toStringAsFixed(4)}',
                                ),
                              if (video.tags.isNotEmpty)
                                Text(video.tags.take(3).join(', ')),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Align(
                  alignment: Alignment.centerRight,
                  child: FilledButton(
                    onPressed: () => _launchVideo(video.id),
                    child: const Text('Watch Video'),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _launchVideo(String videoId) async {
    final appUri = Uri.parse('youtube://watch?v=$videoId');
    final webUri = Uri.parse('https://www.youtube.com/watch?v=$videoId');
    if (await canLaunchUrl(appUri)) {
      await launchUrl(appUri);
      return;
    }
    await launchUrl(webUri, mode: LaunchMode.externalApplication);
  }
}
