import 'dart:math';

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
      appBar: AppBar(title: const Text('Video Locations')),
      body: BlocBuilder<VideosBloc, VideosState>(
        builder: (context, state) {
          if (state is! VideosLoaded) {
            return const Center(child: CircularProgressIndicator());
          }

          final videosWithCoords =
              state.filteredVideos.where((v) => v.hasCoordinates).toList();

          if (videosWithCoords.isEmpty) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(32),
                child: Text(
                  'No videos with location data available.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 16),
                ),
              ),
            );
          }

          final bounds = _calculateBounds(videosWithCoords);

          return FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCameraFit: bounds != null
                  ? CameraFit.bounds(
                      bounds: bounds,
                      padding: const EdgeInsets.all(50),
                    )
                  : null,
            ),
            children: [
              TileLayer(
                urlTemplate:
                    'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.example.ytdash_flutter_claude',
              ),
              MarkerLayer(
                markers: videosWithCoords
                    .map((video) => Marker(
                          point:
                              LatLng(video.latitude!, video.longitude!),
                          width: 40,
                          height: 40,
                          child: GestureDetector(
                            onTap: () =>
                                _showVideoBottomSheet(context, video),
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
                        ))
                    .toList(),
              ),
            ],
          );
        },
      ),
    );
  }

  LatLngBounds? _calculateBounds(List<Video> videos) {
    if (videos.isEmpty) return null;

    double minLat = 90, maxLat = -90, minLng = 180, maxLng = -180;
    for (final video in videos) {
      minLat = min(minLat, video.latitude!);
      maxLat = max(maxLat, video.latitude!);
      minLng = min(minLng, video.longitude!);
      maxLng = max(maxLng, video.longitude!);
    }

    return LatLngBounds(
      LatLng(minLat, minLng),
      LatLng(maxLat, maxLng),
    );
  }

  void _showVideoBottomSheet(BuildContext context, Video video) {
    final dateFormat = DateFormat('yyyy-MM-dd');

    showModalBottomSheet(
      context: context,
      builder: (ctx) => SizedBox(
        height: MediaQuery.of(context).size.height * 0.25,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Thumbnail
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: CachedNetworkImage(
                  imageUrl: video.thumbnailUrl,
                  width: 120,
                  height: 90,
                  fit: BoxFit.cover,
                ),
              ),
              const SizedBox(width: 12),
              // Info
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(video.title,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis),
                      const SizedBox(height: 4),
                      Text(video.channelName,
                          style: TextStyle(
                              color: Theme.of(context).colorScheme.primary,
                              fontSize: 12)),
                      Text(
                          'Published: ${dateFormat.format(video.publishedAt)}',
                          style: const TextStyle(fontSize: 11)),
                      if (video.hasRecordingDate)
                        Text(
                            'Recorded: ${dateFormat.format(video.recordingDate!)}',
                            style: const TextStyle(fontSize: 11)),
                      if (video.hasLocation)
                        Text(video.locationText,
                            style: const TextStyle(fontSize: 11)),
                      if (video.hasCoordinates)
                        Text(
                            'GPS: ${video.latitude!.toStringAsFixed(4)}, ${video.longitude!.toStringAsFixed(4)}',
                            style: const TextStyle(
                                fontSize: 11, color: Colors.grey)),
                      if (video.tags.isNotEmpty)
                        Text(video.tags.take(3).join(', '),
                            style: const TextStyle(
                                fontSize: 11, fontStyle: FontStyle.italic)),
                      const SizedBox(height: 8),
                      SizedBox(
                        height: 32,
                        child: ElevatedButton.icon(
                          onPressed: () => _launchVideo(video.id),
                          icon: const Icon(Icons.play_arrow, size: 16),
                          label: const Text('Watch Video',
                              style: TextStyle(fontSize: 12)),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              // Close button
              IconButton(
                icon: const Icon(Icons.close, size: 20),
                onPressed: () => Navigator.pop(ctx),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _launchVideo(String videoId) async {
    final deepLink = Uri.parse('youtube://watch?v=$videoId');
    final browserUrl =
        Uri.parse('https://www.youtube.com/watch?v=$videoId');

    if (await canLaunchUrl(deepLink)) {
      await launchUrl(deepLink);
    } else {
      await launchUrl(browserUrl, mode: LaunchMode.externalApplication);
    }
  }
}
