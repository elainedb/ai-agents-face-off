import 'package:cached_network_image/cached_network_image.dart';
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
    final mappedVideos = videos.where((video) => video.hasCoordinates).toList();
    if (mappedVideos.isEmpty) {
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

    final center = _computeCenter(mappedVideos);
    final zoom = _computeZoom(mappedVideos);

    return Scaffold(
      appBar: AppBar(title: const Text('Video Map')),
      body: FlutterMap(
        options: MapOptions(initialCenter: center, initialZoom: zoom),
        children: [
          TileLayer(
            urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
            userAgentPackageName: 'com.example.ytdash_flutter_codex',
          ),
          MarkerLayer(
            markers: mappedVideos
                .map(
                  (video) => Marker(
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
                        child: const Icon(
                          Icons.play_arrow,
                          color: Colors.white,
                        ),
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

  LatLng _computeCenter(List<Video> videos) {
    final latitudes = videos.map((item) => item.latitude!).toList();
    final longitudes = videos.map((item) => item.longitude!).toList();
    final lat = (latitudes.reduce((a, b) => a + b)) / latitudes.length;
    final lng = (longitudes.reduce((a, b) => a + b)) / longitudes.length;
    return LatLng(lat, lng);
  }

  double _computeZoom(List<Video> videos) {
    if (videos.length == 1) {
      return 10;
    }

    final latitudes = videos.map((item) => item.latitude!).toList();
    final longitudes = videos.map((item) => item.longitude!).toList();
    final latSpread =
        latitudes.reduce((a, b) => a > b ? a : b) -
        latitudes.reduce((a, b) => a < b ? a : b);
    final lngSpread =
        longitudes.reduce((a, b) => a > b ? a : b) -
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
      isScrollControlled: true,
      builder: (context) => FractionallySizedBox(
        heightFactor: 0.25,
        child: _VideoBottomSheet(video: video),
      ),
    );
  }
}

class _VideoBottomSheet extends StatelessWidget {
  const _VideoBottomSheet({required this.video});

  final Video video;

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('yyyy-MM-dd');

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
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
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        video.title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
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
                Text('Published: ${dateFormat.format(video.publishedAt)}'),
                if (video.recordingDate != null)
                  Text('Recording: ${dateFormat.format(video.recordingDate!)}'),
                Text(video.locationText),
                Text(
                  '${video.latitude!.toStringAsFixed(4)}, ${video.longitude!.toStringAsFixed(4)}',
                ),
                if (video.tags.isNotEmpty)
                  Text(
                    video.tags.take(5).join(', '),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                const SizedBox(height: 8),
                Align(
                  alignment: Alignment.centerLeft,
                  child: FilledButton(
                    onPressed: () => _launchVideo(video.id),
                    child: const Text('Watch Video'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _launchVideo(String videoId) async {
    final deepLink = Uri.parse('youtube://watch?v=$videoId');
    final browserLink = Uri.parse('https://www.youtube.com/watch?v=$videoId');

    if (await canLaunchUrl(deepLink)) {
      await launchUrl(deepLink, mode: LaunchMode.externalApplication);
      return;
    }

    await launchUrl(browserLink, mode: LaunchMode.externalApplication);
  }
}
