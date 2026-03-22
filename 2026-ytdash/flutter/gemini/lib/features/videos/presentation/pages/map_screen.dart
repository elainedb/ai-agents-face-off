import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:intl/intl.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../domain/entities/video.dart';

class MapScreen extends StatefulWidget {
  final List<Video> videos;

  const MapScreen({super.key, required this.videos});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  late List<Video> _videosWithLocation;
  final MapController _mapController = MapController();

  @override
  void initState() {
    super.initState();
    _videosWithLocation = widget.videos.where((v) => v.hasCoordinates).toList();
    
    // Auto-fit bounds after first frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_videosWithLocation.isNotEmpty) {
        _fitBounds();
      }
    });
  }

  void _fitBounds() {
    final points = _videosWithLocation
        .map((v) => LatLng(v.latitude!, v.longitude!))
        .toList();
    
    final bounds = LatLngBounds.fromPoints(points);
    _mapController.fitCamera(
      CameraFit.bounds(
        bounds: bounds,
        padding: const EdgeInsets.all(50.0),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Video Locations'),
        actions: [
          if (_videosWithLocation.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.zoom_out_map),
              onPressed: _fitBounds,
            ),
        ],
      ),
      body: _videosWithLocation.isEmpty
          ? const Center(child: Text('No videos with location data found.'))
          : FlutterMap(
              mapController: _mapController,
              options: MapOptions(
                initialCenter: LatLng(
                  _videosWithLocation.first.latitude!,
                  _videosWithLocation.first.longitude!,
                ),
                initialZoom: 5.0,
              ),
              children: [
                TileLayer(
                  urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  userAgentPackageName: 'com.example.ytdash_flutter_gemini',
                ),
                MarkerLayer(
                  markers: _videosWithLocation.map((video) {
                    return Marker(
                      point: LatLng(video.latitude!, video.longitude!),
                      width: 40,
                      height: 40,
                      child: GestureDetector(
                        onTap: () => _showVideoInfo(context, video),
                        child: Container(
                          decoration: const BoxDecoration(
                            color: Colors.red,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.play_arrow,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
    );
  }

  void _showVideoInfo(BuildContext context, Video video) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        final dateFormat = DateFormat('yyyy-MM-dd');
        return Container(
          padding: const EdgeInsets.all(16.0),
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
                      height: 80,
                      fit: BoxFit.cover,
                    ),
                  ),
                  const SizedBox(width: 16),
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
                        Text(
                          video.channelName,
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              if (video.hasRecordingDate)
                Text(
                  'Recorded: ${dateFormat.format(video.recordingDate!)}',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              if (video.hasLocation)
                Text(
                  'Location: ${video.locationText}',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              Text(
                'Coordinates: ${video.latitude?.toStringAsFixed(4)}, ${video.longitude?.toStringAsFixed(4)}',
                style: Theme.of(context).textTheme.bodySmall,
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () => _launchVideo(video.id),
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
        );
      },
    );
  }

  Future<void> _launchVideo(String videoId) async {
    final youtubeDeepLink = Uri.parse('youtube://www.youtube.com/watch?v=$videoId');
    final youtubeWebUrl = Uri.parse('https://www.youtube.com/watch?v=$videoId');

    try {
      if (await canLaunchUrl(youtubeDeepLink)) {
        await launchUrl(youtubeDeepLink, mode: LaunchMode.externalApplication);
      } else {
        await launchUrl(youtubeWebUrl, mode: LaunchMode.externalApplication);
      }
    } catch (e) {
      debugPrint('Could not launch video: $e');
    }
  }
}
