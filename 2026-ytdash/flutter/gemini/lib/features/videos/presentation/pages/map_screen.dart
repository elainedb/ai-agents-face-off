import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:intl/intl.dart';
import 'package:latlong2/latlong.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../domain/entities/video.dart';

class MapScreen extends StatefulWidget {
  final List<Video> videos;

  const MapScreen({super.key, required this.videos});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  final MapController _mapController = MapController();
  late List<Video> _mappedVideos;

  @override
  void initState() {
    super.initState();
    _mappedVideos = widget.videos.where((v) => v.hasCoordinates).toList();
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_mappedVideos.isNotEmpty) {
        final bounds = LatLngBounds.fromPoints(_mappedVideos.map((v) => LatLng(v.latitude!, v.longitude!)).toList());
        _mapController.fitCamera(
          CameraFit.bounds(
            bounds: bounds,
            padding: const EdgeInsets.all(50.0),
          ),
        );
      }
    });
  }

  void _showBottomSheet(BuildContext context, Video video) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return DraggableScrollableSheet(
          expand: false,
          initialChildSize: 0.4,
          maxChildSize: 0.5,
          minChildSize: 0.2,
          builder: (context, scrollController) {
            return SingleChildScrollView(
              controller: scrollController,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(child: Text(video.title, style: Theme.of(context).textTheme.titleMedium, maxLines: 2, overflow: TextOverflow.ellipsis)),
                        IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(context)),
                      ],
                    ),
                    const SizedBox(height: 8),
                    CachedNetworkImage(
                      imageUrl: video.thumbnailUrl,
                      height: 120,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    ),
                    const SizedBox(height: 8),
                    Text(video.channelName, style: const TextStyle(fontWeight: FontWeight.bold)),
                    Text('Published: ${DateFormat('yyyy-MM-dd').format(video.publishedAt)}'),
                    if (video.hasRecordingDate)
                      Text('Recorded: ${DateFormat('yyyy-MM-dd').format(video.recordingDate!)}'),
                    if (video.hasLocation)
                      Text('Location: ${video.locationText}'),
                    const SizedBox(height: 16),
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
      },
    );
  }

  Future<void> _launchVideo(String videoId) async {
    final appUrl = Uri.parse('youtube://watch?v=$videoId');
    final webUrl = Uri.parse('https://www.youtube.com/watch?v=$videoId');
    
    if (await canLaunchUrl(appUrl)) {
      await launchUrl(appUrl);
    } else {
      await launchUrl(webUrl);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_mappedVideos.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: const Text('Map View')),
        body: const Center(child: Text('No videos with location data available.')),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Map View')),
      body: FlutterMap(
        mapController: _mapController,
        options: const MapOptions(
          initialCenter: LatLng(0, 0),
          initialZoom: 2.0,
        ),
        children: [
          TileLayer(
            urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
            userAgentPackageName: 'dev.elainedb.ytdash_flutter_gemini',
          ),
          MarkerLayer(
            markers: _mappedVideos.map((video) {
              return Marker(
                point: LatLng(video.latitude!, video.longitude!),
                width: 40.0,
                height: 40.0,
                child: GestureDetector(
                  onTap: () => _showBottomSheet(context, video),
                  child: const Icon(Icons.play_circle_fill, color: Colors.red, size: 40.0),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}
