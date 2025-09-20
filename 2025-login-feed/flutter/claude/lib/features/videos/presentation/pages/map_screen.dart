import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:intl/intl.dart';

import '../../domain/entities/video.dart';
import '../bloc/videos_bloc.dart';
import '../bloc/videos_state.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  final MapController _mapController = MapController();
  Video? _selectedVideo;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Video Locations'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: BlocBuilder<VideosBloc, VideosState>(
        builder: (context, state) {
          return state.when(
            initial: () {
              print('MapScreen: VideosBloc state is initial');
              return const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 16),
                    Text('Loading map...'),
                  ],
                ),
              );
            },
            loading: () {
              print('MapScreen: VideosBloc state is loading');
              return const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 16),
                    Text('Loading videos...'),
                  ],
                ),
              );
            },
            loaded: (videos, filteredVideos, selectedChannel, selectedCountry, sortBy, sortOrder, isRefreshing) {
              final videosWithLocation = videos.where((video) => video.hasCoordinates).toList();

              // Debug information
              print('MapScreen Debug:');
              print('Total videos: ${videos.length}');
              print('Videos with coordinates: ${videosWithLocation.length}');
              for (int i = 0; i < videos.length && i < 3; i++) {
                final video = videos[i];
                print('Video $i: ${video.title}');
                print('  - lat: ${video.latitude}, lng: ${video.longitude}');
                print('  - hasCoordinates: ${video.hasCoordinates}');
                print('  - city: ${video.city}, country: ${video.country}');
              }

              if (videosWithLocation.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.location_off, size: 64, color: Colors.grey),
                      const SizedBox(height: 16),
                      const Text(
                        'No videos with location data found',
                        style: TextStyle(fontSize: 18, color: Colors.grey),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Total videos: ${videos.length}',
                        style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Go Back'),
                      ),
                    ],
                  ),
                );
              }

              return _buildMapView(videosWithLocation);
            },
            error: (message) => Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error, size: 64, color: Colors.red),
                  const SizedBox(height: 16),
                  Text('Error: $message'),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Go Back'),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildMapView(List<Video> videos) {
    return Stack(
      children: [
        FlutterMap(
          mapController: _mapController,
          options: MapOptions(
            center: _calculateCenter(videos),
            zoom: _calculateZoom(videos),
            onMapReady: () => _fitBounds(videos),
          ),
          children: [
            TileLayer(
              urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
              userAgentPackageName: 'com.yourcompany.flutter_claude',
              maxNativeZoom: 19,
            ),
            MarkerLayer(
              markers: _buildMarkers(videos),
            ),
          ],
        ),
        if (_selectedVideo != null)
          _buildBottomSheet(_selectedVideo!),
      ],
    );
  }

  LatLng _calculateCenter(List<Video> videos) {
    if (videos.isEmpty) return const LatLng(0, 0);

    double lat = 0;
    double lng = 0;

    for (final video in videos) {
      lat += video.latitude!;
      lng += video.longitude!;
    }

    return LatLng(lat / videos.length, lng / videos.length);
  }

  double _calculateZoom(List<Video> videos) {
    if (videos.length <= 1) return 10.0;

    double minLat = videos.first.latitude!;
    double maxLat = videos.first.latitude!;
    double minLng = videos.first.longitude!;
    double maxLng = videos.first.longitude!;

    for (final video in videos) {
      minLat = minLat < video.latitude! ? minLat : video.latitude!;
      maxLat = maxLat > video.latitude! ? maxLat : video.latitude!;
      minLng = minLng < video.longitude! ? minLng : video.longitude!;
      maxLng = maxLng > video.longitude! ? maxLng : video.longitude!;
    }

    final latDiff = maxLat - minLat;
    final lngDiff = maxLng - minLng;
    final maxDiff = latDiff > lngDiff ? latDiff : lngDiff;

    if (maxDiff > 10) return 2.0;
    if (maxDiff > 5) return 4.0;
    if (maxDiff > 1) return 6.0;
    if (maxDiff > 0.1) return 8.0;
    return 10.0;
  }

  void _fitBounds(List<Video> videos) {
    if (videos.isEmpty) return;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (videos.length == 1) {
        _mapController.move(
          LatLng(videos.first.latitude!, videos.first.longitude!),
          10.0,
        );
        return;
      }

      double minLat = videos.first.latitude!;
      double maxLat = videos.first.latitude!;
      double minLng = videos.first.longitude!;
      double maxLng = videos.first.longitude!;

      for (final video in videos) {
        minLat = minLat < video.latitude! ? minLat : video.latitude!;
        maxLat = maxLat > video.latitude! ? maxLat : video.latitude!;
        minLng = minLng < video.longitude! ? minLng : video.longitude!;
        maxLng = maxLng > video.longitude! ? maxLng : video.longitude!;
      }

      final bounds = LatLngBounds(
        LatLng(minLat, minLng),
        LatLng(maxLat, maxLng),
      );

      _mapController.fitBounds(bounds, options: const FitBoundsOptions(
        padding: EdgeInsets.all(50.0),
      ));
    });
  }

  List<Marker> _buildMarkers(List<Video> videos) {
    return videos.map((video) {
      return Marker(
        point: LatLng(video.latitude!, video.longitude!),
        builder: (context) => GestureDetector(
          onTap: () => _onMarkerTap(video),
          child: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: Colors.red,
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 2),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.3),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: const Icon(
              Icons.play_arrow,
              color: Colors.white,
              size: 20,
            ),
          ),
        ),
      );
    }).toList();
  }

  void _onMarkerTap(Video video) {
    setState(() {
      _selectedVideo = video;
    });
  }

  Widget _buildBottomSheet(Video video) {
    final dateFormat = DateFormat('yyyy-MM-dd');
    final publishedDate = dateFormat.format(video.publishedAt);
    final recordingDate = video.recordingDate != null
        ? dateFormat.format(video.recordingDate!)
        : null;

    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.25,
        ),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
          boxShadow: [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 10,
              offset: Offset(0, -2),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Drag handle
            Container(
              margin: const EdgeInsets.symmetric(vertical: 8),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),

            // Content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Thumbnail
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: CachedNetworkImage(
                            imageUrl: video.thumbnailUrl,
                            width: 80,
                            height: 45,
                            fit: BoxFit.cover,
                            placeholder: (context, url) => Container(
                              width: 80,
                              height: 45,
                              color: Colors.grey[300],
                              child: const Icon(Icons.play_arrow, size: 20),
                            ),
                            errorWidget: (context, url, error) => Container(
                              width: 80,
                              height: 45,
                              color: Colors.grey[300],
                              child: const Icon(Icons.error, size: 20),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),

                        // Video info
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                video.title,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 4),

                              Text(
                                video.channelName,
                                style: TextStyle(
                                  color: Colors.grey[600],
                                  fontSize: 12,
                                ),
                              ),
                              const SizedBox(height: 4),

                              Text(
                                'Published: $publishedDate',
                                style: TextStyle(
                                  color: Colors.grey[600],
                                  fontSize: 11,
                                ),
                              ),

                              if (recordingDate != null) ...[
                                const SizedBox(height: 2),
                                Text(
                                  'Recorded: $recordingDate',
                                  style: TextStyle(
                                    color: Colors.grey[600],
                                    fontSize: 11,
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),

                        // Close button
                        IconButton(
                          onPressed: () => setState(() => _selectedVideo = null),
                          icon: const Icon(Icons.close, size: 20),
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                        ),
                      ],
                    ),

                    const SizedBox(height: 12),

                    // Location info
                    if (video.locationText.isNotEmpty) ...[
                      Row(
                        children: [
                          const Icon(Icons.location_on, size: 16, color: Colors.grey),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              video.locationText,
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                    ],

                    // GPS Coordinates
                    if (video.hasCoordinates) ...[
                      Row(
                        children: [
                          const Icon(Icons.gps_fixed, size: 16, color: Colors.grey),
                          const SizedBox(width: 4),
                          Text(
                            '${video.latitude!.toStringAsFixed(4)}, ${video.longitude!.toStringAsFixed(4)}',
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 11,
                              fontFamily: 'monospace',
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                    ],

                    // Tags
                    if (video.tags.isNotEmpty) ...[
                      Wrap(
                        spacing: 4,
                        runSpacing: 2,
                        children: video.tags.take(3).map((tag) => Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.blue[50],
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.blue[200]!),
                          ),
                          child: Text(
                            tag,
                            style: TextStyle(
                              color: Colors.blue[700],
                              fontSize: 10,
                            ),
                          ),
                        )).toList(),
                      ),
                      const SizedBox(height: 8),
                    ],

                    // Play button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () => _launchVideo(video.id),
                        icon: const Icon(Icons.play_arrow, size: 20),
                        label: const Text('Watch Video'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _launchVideo(String videoId) async {
    final youtubeAppUrl = 'youtube://watch?v=$videoId';
    final youtubeWebUrl = 'https://www.youtube.com/watch?v=$videoId';

    try {
      final youtubeAppUri = Uri.parse(youtubeAppUrl);
      if (await canLaunchUrl(youtubeAppUri)) {
        await launchUrl(youtubeAppUri, mode: LaunchMode.externalApplication);
        return;
      }

      final youtubeWebUri = Uri.parse(youtubeWebUrl);
      if (await canLaunchUrl(youtubeWebUri)) {
        try {
          await launchUrl(youtubeWebUri, mode: LaunchMode.externalApplication);
          return;
        } catch (e) {
          try {
            await launchUrl(youtubeWebUri, mode: LaunchMode.platformDefault);
            return;
          } catch (e2) {
            await launchUrl(youtubeWebUri, mode: LaunchMode.inAppWebView);
            return;
          }
        }
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Could not launch video: $videoId'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error launching video: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    _mapController.dispose();
    super.dispose();
  }
}