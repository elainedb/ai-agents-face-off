import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:ytdash_flutter/data/models/test_config.dart';
import 'package:ytdash_flutter/data/models/video.dart';
import 'package:ytdash_flutter/ui/features/auth/view_models/auth_view_model.dart';
import 'package:ytdash_flutter/ui/features/home/view_models/video_view_model.dart';

class MapScreen extends StatefulWidget {
  final AuthViewModel authViewModel;
  final VideoViewModel videoViewModel;
  final TestConfig config;

  const MapScreen({
    super.key,
    required this.authViewModel,
    required this.videoViewModel,
    required this.config,
  });

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  Video? _selectedVideo;
  final MapController _mapController = MapController();

  @override
  void dispose() {
    _mapController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Extract only videos that have location data
    final locatedVideos = widget.videoViewModel.allVideos
        .where((v) => v.lat != null && v.lng != null)
        .toList();

    // Default map center (e.g. center of the first located video, or fallback)
    final LatLng defaultCenter = locatedVideos.isNotEmpty
        ? LatLng(locatedVideos.first.lat!, locatedVideos.first.lng!)
        : const LatLng(20.0, 0.0);

    return Semantics(
      identifier: 'screen_map',
      child: Scaffold(
        backgroundColor: const Color(0xFF0F0F1A),
        appBar: AppBar(
          backgroundColor: const Color(0xFF16162A),
          elevation: 0,
          title: const Text(
            'Video Map',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ),
        body: Stack(
          children: [
            // 1. Interactive OpenStreetMap
            FlutterMap(
              mapController: _mapController,
              options: MapOptions(
                initialCenter: defaultCenter,
                initialZoom: 3.5,
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
                      width: 50.0,
                      height: 50.0,
                      point: LatLng(video.lat!, video.lng!),
                      child: Semantics(
                        identifier: 'map_marker',
                        button: true,
                        child: GestureDetector(
                          onTap: () {
                            setState(() {
                              _selectedVideo = video;
                            });
                            _mapController.move(LatLng(video.lat!, video.lng!), 5.0);
                          },
                          child: Icon(
                            Icons.location_on,
                            size: isSelected ? 48.0 : 36.0,
                            color: isSelected ? const Color(0xFFFF0055) : const Color(0xFF7A00FF),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),

            // 2. Reachable horizontal native marker chips overlay (bulletproof automation §5)
            Positioned(
              top: 12,
              left: 12,
              right: 12,
              child: SizedBox(
                height: 48,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: locatedVideos.length,
                  itemBuilder: (context, index) {
                    final video = locatedVideos[index];
                    final isSelected = _selectedVideo?.id == video.id;
                    return Padding(
                      padding: const EdgeInsets.only(right: 8.0),
                      child: Semantics(
                        identifier: 'map_marker',
                        button: true,
                        child: ActionChip(
                          backgroundColor: isSelected
                              ? const Color(0xFFFF0055)
                              : const Color(0xFF16162A).withOpacity(0.9),
                          side: BorderSide(
                            color: isSelected
                                ? const Color(0xFFFF0055)
                                : Colors.white.withOpacity(0.1),
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          label: Text(
                            video.title,
                            style: TextStyle(
                              color: isSelected ? Colors.white : Colors.white70,
                              fontSize: 12,
                              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                            ),
                          ),
                          onPressed: () {
                            setState(() {
                              _selectedVideo = video;
                            });
                            _mapController.move(LatLng(video.lat!, video.lng!), 5.0);
                          },
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),

            // 3. Native details sheet overlay (§5a)
            if (_selectedVideo != null)
              Positioned(
                left: 12,
                right: 12,
                bottom: 16,
                child: Semantics(
                  identifier: 'detail_bottom_sheet',
                  child: Card(
                    color: const Color(0xFF16162A).withOpacity(0.95),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24),
                      side: const BorderSide(color: Color(0xFFFF0055), width: 1.5),
                    ),
                    elevation: 8,
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              // Category
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFFF0055).withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  _selectedVideo!.category.toUpperCase(),
                                  style: const TextStyle(
                                    color: Color(0xFFFF0055),
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              // Close button
                              IconButton(
                                icon: const Icon(Icons.close, color: Colors.white60, size: 20),
                                onPressed: () {
                                  setState(() {
                                    _selectedVideo = null;
                                  });
                                },
                                constraints: const BoxConstraints(),
                                padding: EdgeInsets.zero,
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          // Title
                          Text(
                            _selectedVideo!.title,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 6),
                          // Location Name
                          if (_selectedVideo!.locationName != null)
                            Row(
                              children: [
                                const Icon(Icons.location_on, color: Color(0xFF7A00FF), size: 14),
                                const SizedBox(width: 4),
                                Expanded(
                                  child: Text(
                                    _selectedVideo!.locationName!,
                                    style: const TextStyle(
                                      color: Colors.white70,
                                      fontSize: 12,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          const SizedBox(height: 16),

                          // Asserted video URL (MUST contain youtube.com/watch?v=...)
                          Semantics(
                            identifier: 'detail_video_url',
                            child: Text(
                              _selectedVideo!.youtubeUrl,
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.4),
                                fontSize: 11,
                                decoration: TextDecoration.underline,
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),

                          // Open in YouTube Button
                          Semantics(
                            identifier: 'detail_open_youtube_button',
                            button: true,
                            child: SizedBox(
                              width: double.infinity,
                              height: 48,
                              child: ElevatedButton.icon(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFFFF0055),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                onPressed: () {
                                  widget.authViewModel.openVideoUrl(
                                    _selectedVideo!.youtubeUrl,
                                    widget.config,
                                  );
                                },
                                icon: const Icon(Icons.play_arrow, color: Colors.white),
                                label: const Text(
                                  'Open in YouTube',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
