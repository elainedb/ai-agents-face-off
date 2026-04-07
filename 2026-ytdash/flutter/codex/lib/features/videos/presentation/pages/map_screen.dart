import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_cancellable_tile_provider/flutter_map_cancellable_tile_provider.dart';
import 'package:intl/intl.dart';
import 'package:latlong2/latlong.dart';

import '../../domain/entities/video.dart';

class MapScreen extends StatelessWidget {
  const MapScreen({
    super.key,
    required this.videos,
    required this.onWatchVideo,
  });

  final List<Video> videos;
  final ValueChanged<Video> onWatchVideo;

  @override
  Widget build(BuildContext context) {
    final List<Video> mappable = videos
        .where((Video video) => video.hasCoordinates)
        .toList();

    if (mappable.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: const Text('Video Map')),
        body: const Center(
          child: Text('No videos with location data are available.'),
        ),
      );
    }

    final List<LatLng> points = mappable
        .map((Video video) => LatLng(video.latitude!, video.longitude!))
        .toList();

    return Scaffold(
      appBar: AppBar(title: const Text('Video Map')),
      body: FlutterMap(
        options: MapOptions(
          initialCenter: points.first,
          initialZoom: 3,
          cameraConstraint: CameraConstraint.contain(
            bounds: LatLngBounds.fromPoints(points),
          ),
        ),
        children: <Widget>[
          TileLayer(
            urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
            userAgentPackageName: 'dev.elainedb.ytdash_flutter_codex',
            tileProvider: CancellableNetworkTileProvider(),
          ),
          MarkerLayer(
            markers: mappable.map((Video video) {
              return Marker(
                point: LatLng(video.latitude!, video.longitude!),
                width: 48,
                height: 48,
                child: GestureDetector(
                  onTap: () => _showVideoSheet(context, video),
                  child: const CircleAvatar(
                    backgroundColor: Colors.red,
                    child: Icon(Icons.play_arrow, color: Colors.white),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  void _showVideoSheet(BuildContext context, Video video) {
    final DateFormat formatter = DateFormat('yyyy-MM-dd');

    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      constraints: BoxConstraints(
        maxHeight: MediaQuery.sizeOf(context).height * 0.35,
      ),
      builder: (BuildContext context) {
        return Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: SizedBox(
                  width: 140,
                  child: CachedNetworkImage(
                    imageUrl: video.thumbnailUrl,
                    fit: BoxFit.cover,
                    errorWidget: (_, _, _) =>
                        const Icon(Icons.broken_image_outlined),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      video.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 6),
                    Text(video.channelName),
                    Text('Published: ${formatter.format(video.publishedAt)}'),
                    if (video.recordingDate != null)
                      Text(
                        'Recorded: ${formatter.format(video.recordingDate!)}',
                      ),
                    if (video.hasLocation)
                      Text('Location: ${video.locationText}'),
                    Text(
                      'GPS: ${video.latitude!.toStringAsFixed(4)}, ${video.longitude!.toStringAsFixed(4)}',
                    ),
                    const Spacer(),
                    FilledButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                        onWatchVideo(video);
                      },
                      child: const Text('Watch Video'),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
