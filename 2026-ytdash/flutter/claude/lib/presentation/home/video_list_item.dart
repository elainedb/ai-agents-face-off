import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/providers.dart';
import '../../domain/models/video.dart';
import '../external_link/external_link_notifier.dart';

class VideoListItem extends ConsumerWidget {
  const VideoListItem({super.key, required this.video});

  final Video video;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final config = ref.read(testConfigProvider);
    return Semantics(
      identifier: 'video_list_item',
      button: true,
      container: true,
      child: ListTile(
        onTap: () => ref
            .read(externalLinkNotifierProvider.notifier)
            .open(
              video.youtubeUrl,
              captureExternalLinks: config.captureExternalLinks,
            ),
        leading: ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: Image.network(
            video.thumbnailUrl,
            width: 72,
            height: 54,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) => Container(
              width: 72,
              height: 54,
              color: Colors.grey.shade300,
              child: const Icon(Icons.movie, color: Colors.grey),
            ),
          ),
        ),
        title: Text(video.title, maxLines: 1, overflow: TextOverflow.ellipsis),
        subtitle: Text(
          '${video.category} · ${video.publishedAt.toLocal().toString().split(' ').first}\n${video.description}',
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        isThreeLine: true,
      ),
    );
  }
}
