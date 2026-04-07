import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:intl/intl.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../domain/entities/video.dart';

class MapScreen extends StatelessWidget {
  final List<Video> videos;

  const MapScreen({super.key, required this.videos});

  @override
  Widget build(BuildContext context) {
    final mapVideos = videos.where((v) => v.hasCoordinates).toList();

    if (mapVideos.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: const Text('Map View')),
        body: const Center(child: Text('No videos with location data found.')),
      );
    }

    final markers = mapVideos.map((v) => Marker(
      point: LatLng(v.latitude!, v.longitude!),
      width: 40,
      height: 40,
      child: GestureDetector(
        onTap: () => _showBottomSheet(context, v),
        child: const Icon(Icons.play_circle_fill, color: Colors.red, size: 40),
      ),
    )).toList();

    final bounds = LatLngBounds.fromPoints(
      mapVideos.map((v) => LatLng(v.latitude!, v.longitude!)).toList(),
    );

    return Scaffold(
      appBar: AppBar(title: const Text('Map View')),
      body: FlutterMap(
        options: MapOptions(
          initialCameraFit: CameraFit.bounds(
            bounds: bounds,
            padding: const EdgeInsets.all(50.0),
          ),
        ),
        children: [
          TileLayer(
            urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
            userAgentPackageName: 'dev.elainedb.ytdash_flutter_gemini',
          ),
          MarkerLayer(markers: markers),
        ],
      ),
    );
  }

  void _showBottomSheet(BuildContext context, Video video) {
    final df = DateFormat('yyyy-MM-dd');
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return ConstrainedBox(
          constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.4),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        video.title,
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
                Text(video.channelName, style: TextStyle(color: Colors.grey[700])),
                const SizedBox(height: 8),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CachedNetworkImage(
                      imageUrl: video.thumbnailUrl,
                      width: 120,
                      height: 80,
                      fit: BoxFit.cover,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Published: ${df.format(video.publishedAt)}', style: const TextStyle(fontSize: 12)),
                          if (video.hasRecordingDate)
                            Text('Recorded: ${df.format(video.recordingDate!)}', style: const TextStyle(fontSize: 12)),
                          if (video.hasLocation)
                            Text('Location: ${video.locationText}', style: const TextStyle(fontSize: 12)),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Center(
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.play_arrow),
                    label: const Text('Watch Video'),
                    onPressed: () {
                      Navigator.pop(context);
                      _launchVideo(video.id);
                    },
                  ),
                )
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _launchVideo(String id) async {
    final appUrl = Uri.parse('youtube://watch?v=$id');
    final webUrl = Uri.parse('https://www.youtube.com/watch?v=$id');
    
    if (await canLaunchUrl(appUrl)) {
      await launchUrl(appUrl);
    } else {
      await launchUrl(webUrl);
    }
  }
}
