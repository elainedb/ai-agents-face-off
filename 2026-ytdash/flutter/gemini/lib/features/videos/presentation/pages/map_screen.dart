import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../domain/entities/video.dart';
import '../bloc/videos_bloc.dart';
import '../bloc/videos_state.dart';

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
          return state.maybeMap(
            loaded: (currentState) {
              final videosWithLocation = currentState.videos.where((v) => v.hasCoordinates).toList();

              if (videosWithLocation.isEmpty) {
                return const Center(
                  child: Text('No videos with location data available.'),
                );
              }

              final markers = videosWithLocation.map((video) {
                return Marker(
                  point: LatLng(video.latitude!, video.longitude!),
                  width: 40,
                  height: 40,
                  child: GestureDetector(
                    onTap: () => _showVideoDetails(context, video),
                    child: const Icon(
                      Icons.play_circle_fill,
                      color: Colors.red,
                      size: 40,
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
                    padding: const EdgeInsets.all(50.0),
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
            orElse: () => const Center(child: CircularProgressIndicator()),
          );
        },
      ),
    );
  }

  void _showVideoDetails(BuildContext context, Video video) {
    final dateFormat = DateFormat('yyyy-MM-dd');

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return ConstrainedBox(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.4,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Align(
                alignment: Alignment.topRight,
                child: IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          CachedNetworkImage(
                            imageUrl: video.thumbnailUrl,
                            width: 120,
                            height: 68,
                            fit: BoxFit.cover,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  video.title,
                                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  video.channelName,
                                  style: const TextStyle(color: Colors.grey),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Text('Published: ${dateFormat.format(video.publishedAt)}'),
                      if (video.hasRecordingDate) ...[
                        const SizedBox(height: 4),
                        Text('Recorded: ${dateFormat.format(video.recordingDate!)}'),
                      ],
                      const SizedBox(height: 8),
                      Text(
                        [
                          if (video.hasLocation) video.locationText,
                          if (video.hasCoordinates) '(${video.latitude!.toStringAsFixed(4)}, ${video.longitude!.toStringAsFixed(4)})'
                        ].join(' '),
                        style: const TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                      if (video.tags.isNotEmpty) ...[
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 4,
                          children: video.tags.map((tag) => Chip(
                                label: Text(tag, style: const TextStyle(fontSize: 10)),
                                padding: EdgeInsets.zero,
                                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              )).toList(),
                        ),
                      ],
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: () => _launchVideo(video.id),
                          icon: const Icon(Icons.play_arrow),
                          label: const Text('Watch Video'),
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _launchVideo(String videoId) async {
    final appUrl = Uri.parse('youtube://watch?v=$videoId');
    final webUrl = Uri.parse('https://www.youtube.com/watch?v=$videoId');

    if (await canLaunchUrl(appUrl)) {
      await launchUrl(appUrl);
    } else {
      await launchUrl(webUrl, mode: LaunchMode.externalApplication);
    }
  }
}
