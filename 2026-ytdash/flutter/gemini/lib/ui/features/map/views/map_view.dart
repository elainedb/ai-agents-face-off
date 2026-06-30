import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';
import '../../../../data/models/test_config.dart';
import '../../../../data/services/geocoding_service.dart';
import '../../../core/utils/link_launcher.dart';
import '../../dashboard/view_models/dashboard_view_model.dart';
import '../view_models/map_view_model.dart';

class MapView extends StatefulWidget {
  const MapView({super.key});

  @override
  State<MapView> createState() => _MapViewState();
}

class _MapViewState extends State<MapView> {
  final MapController _mapController = MapController();

  @override
  void initState() {
    super.initState();
    // Clear any leftover selection when entering map
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<MapViewModel>().clearSelection();
    });
  }

  @override
  Widget build(BuildContext context) {
    final dashboardViewModel = context.watch<DashboardViewModel>();
    final mapViewModel = context.watch<MapViewModel>();
    final geocodingService = context.read<GeocodingService>();
    final testConfig = context.read<TestConfig>();

    // Get all videos with valid latitude and longitude
    final locatedVideos = dashboardViewModel.filteredVideos
        .where((v) => v.latitude != null && v.longitude != null)
        .toList();

    // Default center to first located video, otherwise Berlin
    final initialCenter = locatedVideos.isNotEmpty
        ? LatLng(locatedVideos.first.latitude!, locatedVideos.first.longitude!)
        : const LatLng(52.5200, 13.4050);

    return Semantics(
      identifier: 'screen_map',
      container: true,
      child: Scaffold(
        backgroundColor: const Color(0xFF0F0C20),
        appBar: AppBar(
          backgroundColor: const Color(0xFF15102A),
          title: const Text('Video Locations Map', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.white)),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: Stack(
          children: [
            // 1. OpenStreetMap Layer
            Positioned.fill(
              child: FlutterMap(
                mapController: _mapController,
                options: MapOptions(
                  initialCenter: initialCenter,
                  initialZoom: 4,
                  minZoom: 2,
                  maxZoom: 18,
                ),
                children: [
                  TileLayer(
                    urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                    userAgentPackageName: 'com.example.ytdash_flutter',
                  ),
                  // Marker Layer with Semantics for Pins
                  MarkerLayer(
                    markers: locatedVideos.map((video) {
                      final isSelected = mapViewModel.selectedVideo?.id == video.id;
                      return Marker(
                        point: LatLng(video.latitude!, video.longitude!),
                        width: 50,
                        height: 50,
                        child: Semantics(
                          identifier: 'map_marker',
                          button: true,
                          child: GestureDetector(
                            onTap: () {
                              mapViewModel.selectVideo(video, geocodingService);
                              _mapController.move(
                                LatLng(video.latitude!, video.longitude!),
                                _mapController.camera.zoom,
                              );
                            },
                            child: AnimatedScale(
                              scale: isSelected ? 1.3 : 1.0,
                              duration: const Duration(milliseconds: 200),
                              child: Icon(
                                Icons.location_on_rounded,
                                color: isSelected ? const Color(0xFFFF0000) : const Color(0xFF2563EB),
                                size: 40,
                                shadows: const [
                                  Shadow(
                                    color: Colors.black45,
                                    blurRadius: 4,
                                    offset: Offset(0, 2),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),

            // 2. Horizontal accessibility-chips row (guaranteed test-mode reachability)
            Positioned(
              top: 16,
              left: 16,
              right: 16,
              child: SizedBox(
                height: 48,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: locatedVideos.length,
                  itemBuilder: (context, index) {
                    final video = locatedVideos[index];
                    final isSelected = mapViewModel.selectedVideo?.id == video.id;

                    return Padding(
                      padding: const EdgeInsets.only(right: 8.0),
                      child: Semantics(
                        identifier: 'map_marker',
                        button: true,
                        child: ActionChip(
                          backgroundColor: isSelected ? const Color(0xFFFF0000) : const Color(0xFF15102A),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                            side: BorderSide(
                              color: isSelected ? const Color(0xFFFF0000) : Colors.white.withOpacity(0.08),
                            ),
                          ),
                          label: Text(
                            video.title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: isSelected ? Colors.white : Colors.white70,
                              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                              fontSize: 12,
                            ),
                          ),
                          onPressed: () {
                            mapViewModel.selectVideo(video, geocodingService);
                            _mapController.move(
                              LatLng(video.latitude!, video.longitude!),
                              _mapController.camera.zoom,
                            );
                          },
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),

            // 3. Inline accessible bottom details sheet (shown when a video is selected)
            if (mapViewModel.selectedVideo != null)
              Positioned(
                left: 16,
                right: 16,
                bottom: 16,
                child: Semantics(
                  identifier: 'detail_bottom_sheet',
                  container: true,
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: const Color(0xFF15102A),
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: Colors.white.withOpacity(0.08), width: 1),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.4),
                          blurRadius: 16,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Row with title and close button
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Text(
                                mapViewModel.selectedVideo!.title,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                  height: 1.3,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            IconButton(
                              icon: const Icon(Icons.close_rounded, color: Colors.white60, size: 20),
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(),
                              onPressed: () => mapViewModel.clearSelection(),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        // Reverse-geocoded place name or loading state
                        Row(
                          children: [
                            const Icon(Icons.location_on_rounded, color: Color(0xFFFF3B30), size: 14),
                            const SizedBox(width: 6),
                            Expanded(
                              child: mapViewModel.isLoadingGeocoding
                                  ? const SizedBox(
                                      height: 12,
                                      width: 12,
                                      child: CircularProgressIndicator(strokeWidth: 1.5, color: Color(0xFFFF3B30)),
                                    )
                                  : Text(
                                      mapViewModel.selectedVideoAddress ?? 'Reverse geocoding location...',
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        color: Colors.white.withOpacity(0.6),
                                        fontSize: 12,
                                      ),
                                    ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        // Requirements: text representation of exact watch URL for link verification
                        Semantics(
                          identifier: 'detail_video_url',
                          container: true,
                          child: Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: Text(
                              mapViewModel.selectedVideo!.youtubeUrl,
                              style: const TextStyle(
                                color: Colors.white38,
                                fontSize: 11,
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                          ),
                        ),
                        // Launch YouTube action button
                        Semantics(
                          identifier: 'detail_open_youtube_button',
                          button: true,
                          container: true,
                          child: ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFFF0000),
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                            ),
                            icon: const Icon(Icons.play_arrow_rounded, color: Colors.white),
                            label: const Text(
                              'Open in YouTube',
                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.white),
                            ),
                            onPressed: () async {
                              await LinkLauncher.launch(
                                mapViewModel.selectedVideo!.youtubeUrl,
                                testConfig: testConfig,
                                dashboardViewModel: dashboardViewModel,
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            if (dashboardViewModel.capturedUrl != null)
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: Semantics(
                  identifier: 'external_open_url',
                  container: true,
                  child: Container(
                    color: const Color(0xFF1E3A8A), // Rich deep blue
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    child: SafeArea(
                      bottom: false,
                      child: Row(
                        children: [
                          const Icon(Icons.link_rounded, color: Colors.white, size: 20),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              dashboardViewModel.capturedUrl!,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.close_rounded, color: Colors.white70, size: 20),
                            onPressed: () {
                              dashboardViewModel.clearCapturedUrl();
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),

            if (dashboardViewModel.externalOpenError != null)
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: Semantics(
                  identifier: 'external_open_error',
                  container: true,
                  child: Container(
                    color: const Color(0xFF7F1D1D), // Dark crimson red
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    child: SafeArea(
                      bottom: false,
                      child: Row(
                        children: [
                          const Icon(Icons.warning_amber_rounded, color: Colors.white, size: 20),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              dashboardViewModel.externalOpenError!,
                              style: const TextStyle(
                                color: Color(0xFFFECACA),
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.close_rounded, color: Colors.white70, size: 20),
                            onPressed: () {
                              dashboardViewModel.clearExternalOpenError();
                            },
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
