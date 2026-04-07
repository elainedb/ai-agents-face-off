import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_cancellable_tile_provider/flutter_map_cancellable_tile_provider.dart';
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
      return Scaffold(
        appBar: AppBar(title: const Text('Video Map')),
        body: const Center(
          child: Padding(
            padding: EdgeInsets.all(24),
            child: Text('No videos currently have coordinate data to show on the map.'),
          ),
        ),
      );
    }

    final bounds = LatLngBounds.fromPoints(
      locatedVideos
          .map((video) => LatLng(video.latitude!, video.longitude!))
          .toList(),
    );

    return Scaffold(
      appBar: AppBar(title: const Text('Video Map')),
      body: FlutterMap(
        options: MapOptions(
          initialCameraFit: CameraFit.bounds(bounds: bounds, padding: const EdgeInsets.all(50)),
        ),
        children: [
          TileLayer(
            urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
            userAgentPackageName: 'dev.elainedb.ytdash_flutter_codex',
            tileProvider: CancellableNetworkTileProvider(),
          ),
          MarkerLayer(
            markers: locatedVideos.map((video) {
              return Marker(
                point: LatLng(video.latitude!, video.longitude!),
                width: 44,
                height: 44,
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

  Future<void> _showVideoSheet(BuildContext context, Video video) async {
    final dateFormat = DateFormat('yyyy-MM-dd');
    await showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.45,
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                height: 120,
                width: double.infinity,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: CachedNetworkImage(imageUrl: video.thumbnailUrl, fit: BoxFit.cover),
                ),
              ),
              const SizedBox(height: 12),
              Text(video.title, style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 8),
              Text(video.channelName),
              Text('Published: ${dateFormat.format(video.publishedAt)}'),
              if (video.recordingDate != null)
                Text('Recorded: ${dateFormat.format(video.recordingDate!)}'),
              if (video.hasLocation) Text('Location: ${video.locationText}'),
              if (video.tags.isNotEmpty) Text('Tags: ${video.tags.take(3).join(', ')}'),
              const SizedBox(height: 12),
              FilledButton(
                onPressed: () => _launchVideo(video.id),
                child: const Text('Watch Video'),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _launchVideo(String videoId) async {
    final deepLink = Uri.parse('youtube://watch?v=$videoId');
    final browserLink = Uri.parse('https://www.youtube.com/watch?v=$videoId');
    if (await canLaunchUrl(deepLink)) {
      await launchUrl(deepLink);
      return;
    }
    await launchUrl(browserLink, mode: LaunchMode.externalApplication);
  }
}
