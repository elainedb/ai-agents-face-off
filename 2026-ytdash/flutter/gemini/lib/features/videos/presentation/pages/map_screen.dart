import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:ytdash_flutter_gemini/features/videos/domain/entities/video.dart';
import 'package:ytdash_flutter_gemini/features/videos/presentation/bloc/videos_bloc.dart';

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
        title: const Text('Map View'),
      ),
      body: BlocBuilder<VideosBloc, VideosState>(
        builder: (context, state) {
          if (state is! VideosLoaded) {
            return const Center(child: CircularProgressIndicator());
          }

          final videosWithLocation = state.filteredVideos.where((v) => v.hasCoordinates).toList();

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
                onTap: () => _showVideoBottomSheet(context, video),
                child: const Icon(
                  Icons.play_circle_fill,
                  color: Colors.red,
                  size: 40,
                ),
              ),
            );
          }).toList();

          WidgetsBinding.instance.addPostFrameCallback((_) {
             _fitBounds(videosWithLocation);
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
                userAgentPackageName: 'com.example.ytdash_flutter_gemini',
              ),
              MarkerLayer(markers: markers),
            ],
          );
        },
      ),
    );
  }

  void _fitBounds(List<Video> videos) {
    if (videos.isEmpty) return;

    double minLat = videos.first.latitude!;
    double maxLat = videos.first.latitude!;
    double minLng = videos.first.longitude!;
    double maxLng = videos.first.longitude!;

    for (var video in videos) {
      if (video.latitude! < minLat) minLat = video.latitude!;
      if (video.latitude! > maxLat) maxLat = video.latitude!;
      if (video.longitude! < minLng) minLng = video.longitude!;
      if (video.longitude! > maxLng) maxLng = video.longitude!;
    }

    final bounds = LatLngBounds(LatLng(minLat, minLng), LatLng(maxLat, maxLng));
    _mapController.fitCamera(
      CameraFit.bounds(
        bounds: bounds,
        padding: const EdgeInsets.all(50.0),
      ),
    );
  }

  void _showVideoBottomSheet(BuildContext context, Video video) {
    final dateFormat = DateFormat('yyyy-MM-dd');
    
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return ConstrainedBox(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.4,
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CachedNetworkImage(
                        imageUrl: video.thumbnailUrl,
                        width: 120,
                        height: 90,
                        fit: BoxFit.cover,
                        placeholder: (context, url) => const Center(child: CircularProgressIndicator()),
                        errorWidget: (context, url, error) => const Icon(Icons.error),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(video.title, style: Theme.of(context).textTheme.titleSmall, maxLines: 2, overflow: TextOverflow.ellipsis),
                            const SizedBox(height: 4),
                            Text(video.channelName, style: Theme.of(context).textTheme.bodySmall?.copyWith(fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => Navigator.pop(context),
                      )
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text('Published: ${dateFormat.format(video.publishedAt)}', style: Theme.of(context).textTheme.bodySmall),
                  if (video.hasRecordingDate)
                    Text('Recorded: ${dateFormat.format(video.recordingDate!)}', style: Theme.of(context).textTheme.bodySmall),
                  if (video.hasLocation)
                    Text('Location: ${video.locationText} (${video.latitude?.toStringAsFixed(4)}, ${video.longitude?.toStringAsFixed(4)})', style: Theme.of(context).textTheme.bodySmall),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
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
          ),
        );
      },
    );
  }

  Future<void> _launchVideo(String videoId) async {
    final Uri appUri = Uri.parse('youtube://watch?v=$videoId');
    final Uri webUri = Uri.parse('https://www.youtube.com/watch?v=$videoId');
    
    try {
      if (await canLaunchUrl(appUri)) {
        await launchUrl(appUri);
      } else {
        await launchUrl(webUri, mode: LaunchMode.externalApplication);
      }
    } catch (e) {
      // Failed to launch
    }
  }
}
