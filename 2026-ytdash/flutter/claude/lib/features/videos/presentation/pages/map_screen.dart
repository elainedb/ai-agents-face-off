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
      appBar: AppBar(
        title: const Text('Video Map'),
      ),
      body: BlocBuilder<VideosBloc, VideosState>(
        builder: (context, state) {
          if (state is! VideosLoaded) {
            return const Center(child: CircularProgressIndicator());
          }

          final videosWithCoords = state.filteredVideos
              .where((v) => v.hasCoordinates)
              .toList();

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
              initialCameraFit: CameraFit.bounds(
                bounds: bounds,
                padding: const EdgeInsets.all(50),
              ),
            ),
            children: [
              TileLayer(
                urlTemplate:
                    'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.example.ytdash_flutter_claude',
              ),
              MarkerLayer(
                markers: videosWithCoords.map((video) {
                  return Marker(
                    point:
                        LatLng(video.latitude!, video.longitude!),
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
        },
      ),
    );
  }

  LatLngBounds _calculateBounds(List<Video> videos) {
    double minLat = 90, maxLat = -90, minLng = 180, maxLng = -180;

    for (final video in videos) {
      minLat = min(minLat, video.latitude!);
      maxLat = max(maxLat, video.latitude!);
      minLng = min(minLng, video.longitude!);
      maxLng = max(maxLng, video.longitude!);
    }

    // Add small padding if all points are at the same location
    if (minLat == maxLat && minLng == maxLng) {
      minLat -= 0.01;
      maxLat += 0.01;
      minLng -= 0.01;
      maxLng += 0.01;
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
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.25,
      ),
      builder: (context) {
        return SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
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
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            video.title,
                            style: Theme.of(context).textTheme.titleSmall,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 2),
                          Text(video.channelName,
                              style: Theme.of(context).textTheme.bodySmall),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                    'Published: ${dateFormat.format(video.publishedAt)}',
                    style: Theme.of(context).textTheme.bodySmall),
                if (video.hasRecordingDate)
                  Text(
                      'Recorded: ${dateFormat.format(video.recordingDate!)}',
                      style: Theme.of(context).textTheme.bodySmall),
                if (video.hasLocation)
                  Text('Location: ${video.locationText}',
                      style: Theme.of(context).textTheme.bodySmall),
                if (video.hasCoordinates)
                  Text(
                      'GPS: ${video.latitude!.toStringAsFixed(4)}, ${video.longitude!.toStringAsFixed(4)}',
                      style: Theme.of(context).textTheme.bodySmall),
                if (video.tags.isNotEmpty)
                  Wrap(
                    spacing: 4,
                    children: video.tags
                        .take(3)
                        .map((t) => Chip(
                              label: Text(t),
                              labelStyle: const TextStyle(fontSize: 10),
                              padding: EdgeInsets.zero,
                              visualDensity: VisualDensity.compact,
                            ))
                        .toList(),
                  ),
                const SizedBox(height: 8),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () async {
                      final deepLink =
                          Uri.parse('youtube://watch?v=${video.id}');
                      final browserUrl = Uri.parse(
                          'https://www.youtube.com/watch?v=${video.id}');
                      if (await canLaunchUrl(deepLink)) {
                        await launchUrl(deepLink);
                      } else {
                        await launchUrl(browserUrl,
                            mode: LaunchMode.externalApplication);
                      }
                    },
                    icon: const Icon(Icons.play_arrow),
                    label: const Text('Watch Video'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                    ),
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
