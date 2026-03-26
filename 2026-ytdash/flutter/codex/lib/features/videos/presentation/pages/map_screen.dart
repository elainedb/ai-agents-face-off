import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:intl/intl.dart';
import 'package:latlong2/latlong.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../domain/entities/video.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key, required this.videos});

  final List<Video> videos;

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  final MapController _mapController = MapController();

  List<Video> get _videosWithCoordinates =>
      widget.videos.where((video) => video.hasCoordinates).toList();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _fitBounds());
  }

  @override
  Widget build(BuildContext context) {
    final videos = _videosWithCoordinates;
    if (videos.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: const Text('Video Map')),
        body: const Center(
          child: Text('No videos with location data are available.'),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Video Map')),
      body: FlutterMap(
        mapController: _mapController,
        options: MapOptions(
          initialCenter: LatLng(
            videos.first.latitude!,
            videos.first.longitude!,
          ),
          initialZoom: 3,
        ),
        children: [
          TileLayer(
            urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
            userAgentPackageName: 'com.example.ytdash_flutter_codex',
          ),
          MarkerLayer(
            markers: videos
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

  void _fitBounds() {
    final videos = _videosWithCoordinates;
    if (videos.isEmpty) {
      return;
    }

    final latitudes = videos.map((video) => video.latitude!).toList();
    final longitudes = videos.map((video) => video.longitude!).toList();
    final bounds = LatLngBounds(
      LatLng(
        latitudes.reduce((a, b) => a < b ? a : b),
        longitudes.reduce((a, b) => a < b ? a : b),
      ),
      LatLng(
        latitudes.reduce((a, b) => a > b ? a : b),
        longitudes.reduce((a, b) => a > b ? a : b),
      ),
    );

    _mapController.fitCamera(
      CameraFit.bounds(bounds: bounds, padding: const EdgeInsets.all(50)),
    );
  }

  Future<void> _launchVideo(String videoId) async {
    final deepLink = Uri.parse('youtube://watch?v=$videoId');
    final browserUrl = Uri.parse('https://www.youtube.com/watch?v=$videoId');
    if (await canLaunchUrl(deepLink)) {
      await launchUrl(deepLink);
      return;
    }
    await launchUrl(browserUrl, mode: LaunchMode.externalApplication);
  }

  void _showVideoSheet(BuildContext context, Video video) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return FractionallySizedBox(
          heightFactor: 0.25,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: CachedNetworkImage(
                        imageUrl: video.thumbnailUrl,
                        width: 110,
                        height: 72,
                        fit: BoxFit.cover,
                        errorWidget: (_, error, stackTrace) => Container(
                          width: 110,
                          height: 72,
                          color: Colors.black12,
                          alignment: Alignment.center,
                          child: const Icon(Icons.broken_image),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            video.title,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          const SizedBox(height: 4),
                          Text(video.channelName),
                          Text(
                            'Published: ${DateFormat('yyyy-MM-dd').format(video.publishedAt)}',
                          ),
                          if (video.recordingDate != null)
                            Text(
                              'Recorded: ${DateFormat('yyyy-MM-dd').format(video.recordingDate!)}',
                            ),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(Icons.close),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                if (video.hasLocation) Text(video.locationText),
                if (video.hasCoordinates)
                  Text(
                    '${video.latitude!.toStringAsFixed(4)}, ${video.longitude!.toStringAsFixed(4)}',
                  ),
                if (video.tags.isNotEmpty)
                  Text(
                    video.tags.take(5).join(', '),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                const Spacer(),
                FilledButton(
                  onPressed: () => _launchVideo(video.id),
                  child: const Text('Watch Video'),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
