import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../domain/entities/video.dart';
import '../bloc/videos_bloc.dart';

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
        title: const Text('Video Locations'),
      ),
      body: BlocBuilder<VideosBloc, VideosState>(
        builder: (context, state) {
          return state.maybeWhen(
            loaded: (videos, filteredVideos, _, __, ___, ____, _____) {
              final videosWithLocation = filteredVideos.where((v) => v.hasCoordinates).toList();

              if (videosWithLocation.isEmpty) {
                return const Center(child: Text('No location data available for current videos.'));
              }

              final markers = videosWithLocation.map((video) {
                return Marker(
                  point: LatLng(video.latitude!, video.longitude!),
                  width: 40,
                  height: 40,
                  child: GestureDetector(
                    onTap: () => _showVideoDetails(context, video),
                    child: const CircleAvatar(
                      backgroundColor: Colors.red,
                      child: Icon(Icons.play_arrow, color: Colors.white, size: 20),
                    ),
                  ),
                );
              }).toList();

              // Auto-fit bounds logic
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (markers.isNotEmpty) {
                  final bounds = LatLngBounds.fromPoints(markers.map((m) => m.point).toList());
                  _mapController.fitCamera(
                    CameraFit.bounds(
                      bounds: bounds,
                      padding: const EdgeInsets.all(50),
                    ),
                  );
                }
              });

              return FlutterMap(
                mapController: _mapController,
                options: const MapOptions(
                  initialCenter: LatLng(0, 0),
                  initialZoom: 2.0,
                ),
                children: [
                  TileLayer(
                    urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                    userAgentPackageName: 'com.example.ytdash',
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
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return DraggableScrollableSheet(
          expand: false,
          initialChildSize: 0.4,
          minChildSize: 0.3,
          maxChildSize: 0.5,
          builder: (context, scrollController) {
            return SingleChildScrollView(
              controller: scrollController,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                         Expanded(
                           child: Text(
                             video.title,
                             style: Theme.of(context).textTheme.titleLarge,
                             maxLines: 2,
                             overflow: TextOverflow.ellipsis,
                           ),
                         ),
                         IconButton(
                           icon: const Icon(Icons.close),
                           onPressed: () => Navigator.of(context).pop(),
                         ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8.0),
                      child: CachedNetworkImage(
                        imageUrl: video.thumbnailUrl,
                        width: double.infinity,
                        height: 150,
                        fit: BoxFit.cover,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      video.channelName,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(color: Colors.grey[700]),
                    ),
                    const SizedBox(height: 8),
                    Text('Published: ${DateFormat('yyyy-MM-dd').format(video.publishedAt)}'),
                    if (video.hasRecordingDate)
                      Text('Recorded: ${DateFormat('yyyy-MM-dd').format(video.recordingDate!)}'),
                    if (video.hasLocation)
                      Text('Location: ${video.locationText}'),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        icon: const Icon(Icons.play_arrow),
                        label: const Text('Watch Video'),
                        onPressed: () {
                          Navigator.of(context).pop();
                          _launchVideo(video.id);
                        },
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Future<void> _launchVideo(String videoId) async {
    final appUrl = Uri.parse('youtube://watch?v=$videoId');
    final webUrl = Uri.parse('https://www.youtube.com/watch?v=$videoId');

    try {
      if (await canLaunchUrl(appUrl)) {
        await launchUrl(appUrl);
      } else {
        await launchUrl(webUrl, mode: LaunchMode.externalApplication);
      }
    } catch (e) {
      // Ignore
    }
  }
}