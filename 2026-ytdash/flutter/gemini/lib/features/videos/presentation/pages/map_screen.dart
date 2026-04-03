import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:intl/intl.dart';
import '../../domain/entities/video.dart';
import '../bloc/videos_bloc.dart';
import '../bloc/videos_state.dart';

class MapScreen extends StatelessWidget {
  const MapScreen({super.key});

  Future<void> _launchVideo(String id) async {
    final nativeUrl = Uri.parse('youtube://watch?v=$id');
    final webUrl = Uri.parse('https://www.youtube.com/watch?v=$id');
    if (await canLaunchUrl(nativeUrl)) {
      await launchUrl(nativeUrl);
    } else {
      await launchUrl(webUrl);
    }
  }

  void _showVideoBottomSheet(BuildContext context, Video video) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        final dateFormat = DateFormat('yyyy-MM-dd');
        return Container(
          constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.35),
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
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
                        Text(video.channelName, style: Theme.of(context).textTheme.bodyMedium),
                        Text('Pub: ${dateFormat.format(video.publishedAt)}', style: Theme.of(context).textTheme.bodySmall),
                        if (video.hasRecordingDate)
                          Text('Rec: ${dateFormat.format(video.recordingDate!)}', style: Theme.of(context).textTheme.bodySmall),
                        if (video.hasLocation)
                          Text(video.locationText, style: Theme.of(context).textTheme.bodySmall),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Center(
                child: FilledButton.icon(
                  onPressed: () => _launchVideo(video.id),
                  icon: const Icon(Icons.play_arrow),
                  label: const Text('Watch Video'),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Map View')),
      body: BlocBuilder<VideosBloc, VideosState>(
        builder: (context, state) {
          if (state is! VideosLoaded) {
            return const Center(child: CircularProgressIndicator());
          }

          final videosWithCoords = state.filteredVideos.where((v) => v.hasCoordinates).toList();

          if (videosWithCoords.isEmpty) {
             return const Center(child: Text('No videos with location data available.'));
          }

          List<Marker> markers = videosWithCoords.map((video) {
            return Marker(
              point: LatLng(video.latitude!, video.longitude!),
              width: 40,
              height: 40,
              child: GestureDetector(
                onTap: () => _showVideoBottomSheet(context, video),
                child: const DecoratedBox(
                  decoration: BoxDecoration(color: Colors.red, shape: BoxShape.circle),
                  child: Icon(Icons.play_arrow, color: Colors.white, size: 24),
                ),
              ),
            );
          }).toList();

          final bounds = LatLngBounds.fromPoints(markers.map((m) => m.point).toList());

          return FlutterMap(
            options: MapOptions(
              initialCameraFit: CameraFit.bounds(bounds: bounds, padding: const EdgeInsets.all(50)),
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.example.app',
              ),
              MarkerLayer(markers: markers),
            ],
          );
        },
      ),
    );
  }
}
