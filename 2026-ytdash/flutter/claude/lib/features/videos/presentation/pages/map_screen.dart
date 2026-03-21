import 'package:cached_network_image/cached_network_image.dart';
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
      appBar: AppBar(title: const Text('Video Map')),
      body: BlocBuilder<VideosBloc, VideosState>(
        builder: (context, state) {
          return state.when(
            initial: () => const Center(child: CircularProgressIndicator()),
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (message) => Center(child: Text(message)),
            loaded: (videos, filteredVideos, selectedChannel, selectedCountry, sortBy, sortOrder, isRefreshing) {
              final videosWithCoords =
                  videos.where((v) => v.hasCoordinates).toList();

              if (videosWithCoords.isEmpty) {
                return const Center(
                  child: Text('No videos with location data available.'),
                );
              }

              return FlutterMap(
                mapController: _mapController,
                options: MapOptions(
                  initialCenter: _calculateCenter(videosWithCoords),
                  initialZoom: _calculateZoom(videosWithCoords),
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
          );
        },
      ),
    );
  }

  LatLng _calculateCenter(List<Video> videos) {
    double lat = 0, lng = 0;
    for (final v in videos) {
      lat += v.latitude!;
      lng += v.longitude!;
    }
    return LatLng(lat / videos.length, lng / videos.length);
  }

  double _calculateZoom(List<Video> videos) {
    if (videos.length == 1) return 12;

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
    if (maxDiff < 1) return 8;
    if (maxDiff < 10) return 5;
    if (maxDiff < 50) return 3;
    return 2;
  }

  void _showVideoBottomSheet(BuildContext context, Video video) {
    final dateFormat = DateFormat('yyyy-MM-dd');

    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Container(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.25,
          ),
          padding: const EdgeInsets.all(12),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: CachedNetworkImage(
                        imageUrl: video.thumbnailUrl,
                        width: 120,
                        height: 68,
                        fit: BoxFit.cover,
                      ),
                    ),
                    const SizedBox(width: 8),
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
                const SizedBox(height: 4),
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
                        .map((tag) => Chip(
                              label: Text(tag,
                                  style: const TextStyle(fontSize: 10)),
                              materialTapTargetSize:
                                  MaterialTapTargetSize.shrinkWrap,
                              visualDensity: VisualDensity.compact,
                            ))
                        .toList(),
                  ),
                const SizedBox(height: 4),
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
    final browserUrl =
        Uri.parse('https://www.youtube.com/watch?v=$videoId');

    if (await canLaunchUrl(deepLink)) {
      await launchUrl(deepLink);
    } else {
      await launchUrl(browserUrl, mode: LaunchMode.externalApplication);
    }
  }
}
