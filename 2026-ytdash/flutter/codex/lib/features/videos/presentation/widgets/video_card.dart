import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../domain/entities/video.dart';

class VideoCard extends StatelessWidget {
  const VideoCard({super.key, required this.video, required this.onPlay});

  final Video video;
  final VoidCallback onPlay;

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('yyyy-MM-dd');
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: AspectRatio(
                aspectRatio: 16 / 9,
                child: CachedNetworkImage(
                  imageUrl: video.thumbnailUrl,
                  fit: BoxFit.cover,
                  placeholder: (context, url) => const ColoredBox(
                    color: Colors.black12,
                    child: Center(child: CircularProgressIndicator()),
                  ),
                  errorWidget: (context, url, error) => const ColoredBox(
                    color: Colors.black12,
                    child: Center(child: Icon(Icons.broken_image_outlined)),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
            Text(video.title, style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            Text(video.channelName),
            const SizedBox(height: 4),
            Text('Published: ${dateFormat.format(video.publishedAt)}'),
            if (video.recordingDate != null)
              Text('Recording: ${dateFormat.format(video.recordingDate!)}'),
            if (video.hasLocation) Text('Location: ${video.locationText}'),
            if (video.hasCoordinates)
              Text(
                'GPS: ${video.latitude!.toStringAsFixed(4)}, '
                '${video.longitude!.toStringAsFixed(4)}',
              ),
            if (video.tags.isNotEmpty) ...<Widget>[
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: <Widget>[
                  for (final tag in video.tags.take(3)) Chip(label: Text(tag)),
                  if (video.tags.length > 3)
                    Chip(label: Text('+${video.tags.length - 3} more')),
                ],
              ),
            ],
            const SizedBox(height: 12),
            Align(
              alignment: Alignment.centerRight,
              child: FloatingActionButton.small(
                heroTag: 'play-${video.id}',
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
                onPressed: onPlay,
                child: const Icon(Icons.play_arrow),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
