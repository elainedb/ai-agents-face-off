import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:intl/intl.dart';
import 'package:latlong2/latlong.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:ytdash_flutter_claude/features/videos/domain/entities/video.dart';
import 'package:ytdash_flutter_claude/features/videos/presentation/bloc/videos_bloc.dart';
import 'package:ytdash_flutter_claude/features/videos/presentation/bloc/videos_state.dart';

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

          final videosWithLocation =
              state.videos.where((v) => v.hasCoordinates).toList();

          if (videosWithLocation.isEmpty) {
            return const Center(
              child: Text('No videos with location data available.'),
            );
          }

          return FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: _calculateCenter(videosWithLocation),
              initialZoom: _calculateZoom(videosWithLocation),
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'dev.elainedb.ytdash_flutter_claude',
              ),
              MarkerLayer(
                markers: videosWithLocation
                    .map((video) => Marker(
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
                              child: const Icon(Icons.play_arrow,
                                  color: Colors.white, size: 24),
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

  LatLng _calculateCenter(List<Video> videos) {
    double sumLat = 0, sumLng = 0;
    for (final v in videos) {
      sumLat += v.latitude!;
      sumLng += v.longitude!;
    }
    return LatLng(sumLat / videos.length, sumLng / videos.length);
  }

  double _calculateZoom(List<Video> videos) {
    if (videos.length <= 1) return 10;

    double minLat = 90, maxLat = -90, minLng = 180, maxLng = -180;
    for (final v in videos) {
      if (v.latitude! < minLat) minLat = v.latitude!;
      if (v.latitude! > maxLat) maxLat = v.latitude!;
      if (v.longitude! < minLng) minLng = v.longitude!;
      if (v.longitude! > maxLng) maxLng = v.longitude!;
    }

    final latDiff = maxLat - minLat;
    final lngDiff = maxLng - minLng;
    final maxDiff = latDiff > lngDiff ? latDiff : lngDiff;

    if (maxDiff < 0.01) return 14;
    if (maxDiff < 0.1) return 12;
    if (maxDiff < 1) return 9;
    if (maxDiff < 10) return 6;
    if (maxDiff < 50) return 4;
    return 2;
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
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(video.title,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ],
                ),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(
                        video.thumbnailUrl,
                        width: 100,
                        height: 75,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) =>
                            Container(
                          color: Colors.grey[300],
                          width: 100,
                          height: 75,
                          child: const Icon(Icons.error),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(video.channelName),
                          Text(
                              'Published: ${dateFormat.format(video.publishedAt)}'),
                          if (video.hasRecordingDate)
                            Text(
                                'Recorded: ${dateFormat.format(video.recordingDate!)}'),
                          if (video.hasLocation) Text(video.locationText),
                          if (video.hasCoordinates)
                            Text(
                                'GPS: ${video.latitude!.toStringAsFixed(4)}, ${video.longitude!.toStringAsFixed(4)}'),
                        ],
                      ),
                    ),
                  ],
                ),
                if (video.tags.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Wrap(
                      spacing: 4,
                      children: video.tags
                          .take(3)
                          .map((t) => Chip(
                                label: Text(t,
                                    style: const TextStyle(fontSize: 10)),
                                visualDensity: VisualDensity.compact,
                                padding: EdgeInsets.zero,
                              ))
                          .toList(),
                    ),
                  ),
                const SizedBox(height: 8),
                SizedBox(
                  width: double.infinity,
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

  Future<void> _launchVideo(String videoId) async {
    final deepLink = Uri.parse('youtube://watch?v=$videoId');
    final webUrl = Uri.parse('https://www.youtube.com/watch?v=$videoId');

    if (await canLaunchUrl(deepLink)) {
      await launchUrl(deepLink);
    } else {
      await launchUrl(webUrl, mode: LaunchMode.externalApplication);
    }
  }
}
