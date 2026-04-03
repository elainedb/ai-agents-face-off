import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:intl/intl.dart';
import 'package:latlong2/latlong.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../domain/entities/video.dart';
import '../bloc/videos_bloc.dart';

class MapScreen extends StatelessWidget {
  const MapScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Video Locations'),
      ),
      body: BlocBuilder<VideosBloc, VideosState>(
        builder: (context, state) {
          if (state is! VideosLoaded) {
            return const Center(child: CircularProgressIndicator());
          }

          final videosWithLocation = state.filteredVideos
              .where((v) => v.hasCoordinates)
              .toList();

          if (videosWithLocation.isEmpty) {
            return const Center(
              child: Text('No videos with location data found.'),
            );
          }

          final markers = videosWithLocation.map((video) {
            return Marker(
              point: LatLng(video.latitude!, video.longitude!),
              width: 40,
              height: 40,
              child: GestureDetector(
                onTap: () => _showVideoDetails(context, video),
                child: Container(
                  decoration: const BoxDecoration(
                    color: Colors.red,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.play_arrow, color: Colors.white, size: 24),
                ),
              ),
            );
          }).toList();

          final bounds = LatLngBounds.fromPoints(
            videosWithLocation.map((v) => LatLng(v.latitude!, v.longitude!)).toList(),
          );

          return FlutterMap(
            options: MapOptions(
              initialCameraFit: CameraFit.bounds(
                bounds: bounds,
                padding: const EdgeInsets.all(50),
              ),
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.example.ytdash_flutter_gemini',
              ),
              MarkerLayer(markers: markers),
            ],
          );
        },
      ),
    );
  }

  void _showVideoDetails(BuildContext context, Video video) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        final dateFormat = DateFormat('yyyy-MM-dd');
        final pubDate = dateFormat.format(video.publishedAt);
        final recDate = video.hasRecordingDate ? dateFormat.format(video.recordingDate!) : 'Unknown';

        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        video.title,
                        style: Theme.of(context).textTheme.titleMedium,
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
                    SizedBox(
                      width: 120,
                      child: AspectRatio(
                        aspectRatio: 16 / 9,
                        child: CachedNetworkImage(
                          imageUrl: video.thumbnailUrl,
                          fit: BoxFit.cover,
                          placeholder: (context, url) => const Center(child: CircularProgressIndicator()),
                          errorWidget: (context, url, error) => const Center(child: Icon(Icons.error)),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(video.channelName, style: const TextStyle(fontWeight: FontWeight.bold)),
                          Text('Pub: $pubDate', style: Theme.of(context).textTheme.bodySmall),
                          Text('Rec: $recDate', style: Theme.of(context).textTheme.bodySmall),
                          if (video.hasLocation)
                            Text(video.locationText, style: Theme.of(context).textTheme.bodySmall),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  onPressed: () async {
                    final nativeUrl = Uri.parse('youtube://watch?v=${video.id}');
                    final webUrl = Uri.parse('https://www.youtube.com/watch?v=${video.id}');
                    try {
                      if (await canLaunchUrl(nativeUrl)) {
                        await launchUrl(nativeUrl, mode: LaunchMode.externalApplication);
                      } else {
                        await launchUrl(webUrl, mode: LaunchMode.externalApplication);
                      }
                    } catch (e) {
                      debugPrint('Could not launch video: $e');
                    }
                  },
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
        );
      },
    );
  }
}
