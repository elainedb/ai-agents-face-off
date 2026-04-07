import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:intl/intl.dart';
import 'package:latlong2/latlong.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:ytdash_flutter_claude/features/videos/domain/entities/video.dart';
import 'package:ytdash_flutter_claude/features/videos/presentation/bloc/videos_bloc.dart';

class MapScreen extends StatelessWidget {
  const MapScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Video Map')),
      body: BlocBuilder<VideosBloc, VideosState>(
        builder: (context, state) {
          if (state is! VideosLoaded) {
            return const Center(child: CircularProgressIndicator());
          }

          final videosWithCoords =
              state.filteredVideos.where((v) => v.hasCoordinates).toList();

          if (videosWithCoords.isEmpty) {
            return const Center(
              child: Text('No videos with location data available.'),
            );
          }

          final bounds = LatLngBounds.fromPoints(
            videosWithCoords
                .map((v) => LatLng(v.latitude!, v.longitude!))
                .toList(),
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
                userAgentPackageName: 'dev.elainedb.ytdash_flutter_claude',
              ),
              MarkerLayer(
                markers: videosWithCoords.map((video) {
                  return Marker(
                    point: LatLng(video.latitude!, video.longitude!),
                    width: 36,
                    height: 36,
                    child: GestureDetector(
                      onTap: () => _showVideoBottomSheet(context, video),
                      child: Container(
                        decoration: const BoxDecoration(
                          color: Colors.red,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.play_arrow,
                            color: Colors.white, size: 20),
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

  void _showVideoBottomSheet(BuildContext context, Video video) {
    final dateFormat = DateFormat('yyyy-MM-dd');

    showModalBottomSheet(
      context: context,
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.25,
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(video.title,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              Expanded(
                child: SingleChildScrollView(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: CachedNetworkImage(
                          imageUrl: video.thumbnailUrl,
                          width: 100,
                          height: 75,
                          fit: BoxFit.cover,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(video.channelName,
                                style:
                                    Theme.of(context).textTheme.bodySmall),
                            Text(
                                'Published: ${dateFormat.format(video.publishedAt)}',
                                style:
                                    Theme.of(context).textTheme.bodySmall),
                            if (video.hasRecordingDate)
                              Text(
                                  'Recorded: ${dateFormat.format(video.recordingDate!)}',
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodySmall),
                            if (video.hasLocation)
                              Text(video.locationText,
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodySmall),
                            if (video.hasCoordinates)
                              Text(
                                  'GPS: ${video.latitude!.toStringAsFixed(4)}, ${video.longitude!.toStringAsFixed(4)}',
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodySmall),
                            if (video.tags.isNotEmpty)
                              Text(
                                  'Tags: ${video.tags.take(3).join(", ")}${video.tags.length > 3 ? " +${video.tags.length - 3} more" : ""}',
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodySmall),
                            const SizedBox(height: 8),
                            SizedBox(
                              height: 32,
                              child: ElevatedButton.icon(
                                onPressed: () async {
                                  final deepLink = Uri.parse(
                                      'youtube://watch?v=${video.id}');
                                  final webUrl = Uri.parse(
                                      'https://www.youtube.com/watch?v=${video.id}');
                                  if (await canLaunchUrl(deepLink)) {
                                    await launchUrl(deepLink);
                                  } else {
                                    await launchUrl(webUrl,
                                        mode:
                                            LaunchMode.externalApplication);
                                  }
                                },
                                icon: const Icon(Icons.play_arrow, size: 16),
                                label: const Text('Watch Video',
                                    style: TextStyle(fontSize: 12)),
                              ),
                            ),
                          ],
                        ),
                      ),
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
}
