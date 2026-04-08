import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:intl/intl.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../domain/entities/video.dart';
import '../bloc/videos_bloc.dart';

class MapScreen extends StatelessWidget {
  const MapScreen({super.key});

  Future<void> _launchVideo(String videoId) async {
    final Uri appUri = Uri.parse('youtube://watch?v=$videoId');
    final Uri webUri = Uri.parse('https://www.youtube.com/watch?v=$videoId');

    if (await canLaunchUrl(appUri)) {
      await launchUrl(appUri);
    } else {
      await launchUrl(webUri, mode: LaunchMode.externalApplication);
    }
  }

  void _showVideoBottomSheet(BuildContext context, Video video) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        final dateFormat = DateFormat('yyyy-MM-dd');
        final String pubDate = dateFormat.format(video.publishedAt);
        final String recDate = video.recordingDate != null ? dateFormat.format(video.recordingDate!) : 'Unknown';

        return SafeArea(
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
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CachedNetworkImage(
                      imageUrl: video.thumbnailUrl,
                      width: 120,
                      height: 90,
                      fit: BoxFit.cover,
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(video.channelName, style: const TextStyle(color: Colors.grey)),
                          const SizedBox(height: 4),
                          Text('Pub: $pubDate', style: const TextStyle(fontSize: 12)),
                          Text('Rec: $recDate', style: const TextStyle(fontSize: 12)),
                          if (video.hasLocation)
                            Text(video.locationText, style: const TextStyle(fontSize: 12)),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Center(
                  child: ElevatedButton.icon(
                    onPressed: () => _launchVideo(video.id),
                    icon: const Icon(Icons.play_arrow),
                    label: const Text('Watch Video'),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Video Locations')),
      body: BlocBuilder<VideosBloc, VideosState>(
        builder: (context, state) {
          return state.maybeMap(
            loaded: (loadedState) {
              final mappedVideos = loadedState.filteredVideos.where((v) => v.hasCoordinates).toList();

              if (mappedVideos.isEmpty) {
                return const Center(child: Text('No videos with location data found.'));
              }

              final markers = mappedVideos.map((video) {
                return Marker(
                  point: LatLng(video.latitude!, video.longitude!),
                  width: 40,
                  height: 40,
                  child: GestureDetector(
                    onTap: () => _showVideoBottomSheet(context, video),
                    child: const Icon(Icons.play_circle_fill, color: Colors.red, size: 40),
                  ),
                );
              }).toList();

              final mapController = MapController();

              // Calculate bounds
              double minLat = mappedVideos.first.latitude!;
              double maxLat = mappedVideos.first.latitude!;
              double minLng = mappedVideos.first.longitude!;
              double maxLng = mappedVideos.first.longitude!;

              for (var video in mappedVideos) {
                if (video.latitude! < minLat) minLat = video.latitude!;
                if (video.latitude! > maxLat) maxLat = video.latitude!;
                if (video.longitude! < minLng) minLng = video.longitude!;
                if (video.longitude! > maxLng) maxLng = video.longitude!;
              }

              final bounds = LatLngBounds(
                LatLng(minLat, minLng),
                LatLng(maxLat, maxLng),
              );

              return FlutterMap(
                mapController: mapController,
                options: MapOptions(
                  initialCameraFit: CameraFit.bounds(bounds: bounds, padding: const EdgeInsets.all(50)),
                ),
                children: [
                  TileLayer(
                    urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                    userAgentPackageName: 'dev.elainedb.ytdash_flutter_gemini',
                  ),
                  MarkerLayer(markers: markers),
                ],
              );
            },
            orElse: () => const Center(child: CircularProgressIndicator()),
          );
        },
      ),
    );
  }
}
