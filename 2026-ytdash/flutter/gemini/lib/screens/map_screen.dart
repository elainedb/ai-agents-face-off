import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/video.dart';
import '../services/app_state.dart';

class MapScreen extends StatefulWidget {
  final AppStateNotifier appState;
  final VoidCallback onBack;

  const MapScreen({
    super.key,
    required this.appState,
    required this.onBack,
  });

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  final MapController _mapController = MapController();
  Video? _selectedVideo;

  @override
  Widget build(BuildContext context) {
    final state = widget.appState;
    final locatedVideos = state.videos.where((v) => v.lat != null && v.lng != null).toList();

    // Default center to first video coordinate, or center of Europe if empty
    final LatLng defaultCenter = locatedVideos.isNotEmpty
        ? LatLng(locatedVideos.first.lat!, locatedVideos.first.lng!)
        : const LatLng(48.8566, 2.3522);

    return Semantics(
      identifier: 'screen_map',
      container: true,
      child: Scaffold(
        backgroundColor: const Color(0xFF0F172A),
        appBar: AppBar(
          backgroundColor: const Color(0xFF1E293B),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
            onPressed: widget.onBack,
          ),
          title: const Text(
            'Map Locations',
            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
          ),
        ),
        body: Stack(
          children: [
            // 1. The main OpenStreetMap map
            FlutterMap(
              mapController: _mapController,
              options: MapOptions(
                initialCenter: defaultCenter,
                initialZoom: 4.0,
              ),
              children: [
                TileLayer(
                  urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  userAgentPackageName: 'com.example.ytdash_flutter',
                ),
                MarkerLayer(
                  markers: locatedVideos.map((video) {
                    final isSelected = _selectedVideo?.id == video.id;
                    return Marker(
                      point: LatLng(video.lat!, video.lng!),
                      width: 50,
                      height: 50,
                      child: Semantics(
                        identifier: 'map_marker',
                        container: true,
                        button: true,
                        child: GestureDetector(
                          onTap: () {
                            setState(() {
                              _selectedVideo = video;
                            });
                            _mapController.move(LatLng(video.lat!, video.lng!), _mapController.camera.zoom);
                          },
                          child: Icon(
                            Icons.location_on_rounded,
                            color: isSelected ? Colors.amberAccent : Colors.redAccent,
                            size: isSelected ? 48 : 40,
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),

            // 2. Horizontal scrollable accessible marker chips (as required by constitution §5 / cross-framework-setup §C)
            if (locatedVideos.isNotEmpty)
              Positioned(
                top: 16,
                left: 0,
                right: 0,
                height: 50,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: locatedVideos.length,
                  itemBuilder: (context, index) {
                    final video = locatedVideos[index];
                    final isSelected = _selectedVideo?.id == video.id;
                    return Padding(
                      padding: const EdgeInsets.only(right: 12),
                      child: Semantics(
                        identifier: 'map_marker',
                        container: true,
                        button: true,
                        child: ActionChip(
                          backgroundColor: isSelected ? Colors.amberAccent : const Color(0xFF1E293B),
                          side: BorderSide(
                            color: isSelected ? Colors.amberAccent : Colors.white30,
                          ),
                          label: Text(
                            video.title,
                            style: TextStyle(
                              color: isSelected ? Colors.black87 : Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          onPressed: () {
                            setState(() {
                              _selectedVideo = video;
                            });
                            _mapController.move(LatLng(video.lat!, video.lng!), 6.0);
                          },
                        ),
                      ),
                    );
                  },
                ),
              ),

            // 3. Detail Bottom Sheet (as requested, inline absolute alignment so it's fully accessible to E2E)
            if (_selectedVideo != null)
              _buildDetailBottomSheet(_selectedVideo!),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailBottomSheet(Video video) {
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: Semantics(
        identifier: 'detail_bottom_sheet',
        container: true,
        child: Container(
          decoration: const BoxDecoration(
            color: Color(0xFF1E293B),
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            boxShadow: [
              BoxShadow(
                color: Colors.black45,
                blurRadius: 10,
                spreadRadius: 2,
                offset: Offset(0, -2),
              ),
            ],
          ),
          padding: const EdgeInsets.all(20),
          child: SafeArea(
            top: false,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        video.title,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close_rounded, color: Colors.white70),
                      onPressed: () {
                        setState(() {
                          _selectedVideo = null;
                        });
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(
                        video.thumbnailUrl,
                        width: 120,
                        height: 68,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => Container(
                          width: 120,
                          height: 68,
                          color: Colors.grey[800],
                          child: const Icon(Icons.video_library_rounded, color: Colors.white30),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            video.description,
                            maxLines: 3,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(color: Colors.white70, fontSize: 13),
                          ),
                          const SizedBox(height: 8),
                          Semantics(
                            identifier: 'detail_video_url',
                            container: true,
                            child: Text(
                              video.youtubeUrl,
                              style: const TextStyle(
                                color: Colors.redAccent,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Semantics(
                  identifier: 'detail_open_youtube_button',
                  container: true,
                  button: true,
                  child: ElevatedButton.icon(
                    onPressed: () => _launchVideo(video),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.redAccent,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    icon: const Icon(Icons.play_arrow_rounded),
                    label: const Text(
                      'Open in YouTube',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _launchVideo(Video video) async {
    if (widget.appState.config.captureExternalLinks) {
      widget.appState.captureUrl(video.youtubeUrl);
    } else {
      try {
        final Uri url = Uri.parse(video.youtubeUrl);
        if (await canLaunchUrl(url)) {
          await launchUrl(url, mode: LaunchMode.externalApplication);
        } else {
          throw 'Could not launch $url';
        }
      } catch (e) {
        widget.appState.setExternalOpenError('Failed to launch YouTube app: $e');
      }
    }
  }
}
