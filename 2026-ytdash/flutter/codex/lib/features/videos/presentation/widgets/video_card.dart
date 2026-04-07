import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../domain/entities/video.dart';

class VideoCard extends StatelessWidget {
  const VideoCard({super.key, required this.video, required this.onWatch});

  final Video video;
  final VoidCallback onWatch;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final DateFormat formatter = DateFormat('yyyy-MM-dd');

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
                  placeholder: (_, _) => const ColoredBox(
                    color: Color(0xFFE0E0E0),
                    child: Center(child: CircularProgressIndicator()),
                  ),
                  errorWidget: (_, _, _) => const ColoredBox(
                    color: Color(0xFFE0E0E0),
                    child: Icon(Icons.broken_image_outlined),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
            Text(video.title, style: theme.textTheme.titleMedium),
            const SizedBox(height: 6),
            Text(video.channelName, style: theme.textTheme.bodyMedium),
            const SizedBox(height: 8),
            Text('Published: ${formatter.format(video.publishedAt)}'),
            if (video.recordingDate != null)
              Text('Recorded: ${formatter.format(video.recordingDate!)}'),
            if (video.hasLocation) Text('Location: ${video.locationText}'),
            if (video.hasCoordinates)
              Text(
                'GPS: ${video.latitude!.toStringAsFixed(4)}, ${video.longitude!.toStringAsFixed(4)}',
              ),
            if (video.tags.isNotEmpty) ...<Widget>[
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: <Widget>[
                  for (final String tag in video.tags.take(3))
                    Chip(label: Text(tag)),
                  if (video.tags.length > 3)
                    Chip(label: Text('+${video.tags.length - 3} more')),
                ],
              ),
            ],
            const SizedBox(height: 12),
            Align(
              alignment: Alignment.centerRight,
              child: FloatingActionButton.small(
                heroTag: 'watch-${video.id}',
                backgroundColor: Colors.red,
                onPressed: onWatch,
                child: const Icon(Icons.play_arrow),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
