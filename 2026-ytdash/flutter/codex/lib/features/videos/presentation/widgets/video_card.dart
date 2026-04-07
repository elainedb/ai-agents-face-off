import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../domain/entities/video.dart';

class VideoCard extends StatelessWidget {
  const VideoCard({
    super.key,
    required this.video,
    required this.onPlay,
  });

  final Video video;
  final VoidCallback onPlay;

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('yyyy-MM-dd');
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AspectRatio(
              aspectRatio: 16 / 9,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: CachedNetworkImage(
                  imageUrl: video.thumbnailUrl,
                  fit: BoxFit.cover,
                  placeholder: (_, _) =>
                      const Center(child: CircularProgressIndicator()),
                  errorWidget: (_, _, _) => Container(
                    color: Theme.of(context).colorScheme.surfaceContainerHighest,
                    alignment: Alignment.center,
                    child: const Icon(Icons.broken_image_outlined, size: 40),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
            Text(video.title, style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            Text(video.channelName),
            const SizedBox(height: 8),
            Text('Published: ${dateFormat.format(video.publishedAt)}'),
            if (video.recordingDate != null)
              Text('Recorded: ${dateFormat.format(video.recordingDate!)}'),
            if (video.hasLocation)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text('Location: ${video.locationText}'),
              ),
            if (video.hasCoordinates)
              Text(
                'GPS: ${video.latitude!.toStringAsFixed(4)}, '
                '${video.longitude!.toStringAsFixed(4)}',
              ),
            if (video.tags.isNotEmpty) ...[
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final tag in video.tags.take(3))
                    Chip(label: Text(tag), visualDensity: VisualDensity.compact),
                  if (video.tags.length > 3)
                    Chip(
                      label: Text('+${video.tags.length - 3} more'),
                      visualDensity: VisualDensity.compact,
                    ),
                ],
              ),
            ],
            const SizedBox(height: 12),
            Align(
              alignment: Alignment.centerRight,
              child: FloatingActionButton.small(
                heroTag: 'play-${video.id}',
                onPressed: onPlay,
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
                child: const Icon(Icons.play_arrow),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
