import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/providers.dart';
import '../../domain/models/video.dart';
import '../external_link/external_link_notifier.dart';

/// Shown after tapping a `map_marker` (constitution §3): carries `detail_video_url` (the exact
/// watch URL for the tapped video) and `detail_open_youtube_button`.
class DetailBottomSheet extends ConsumerWidget {
  const DetailBottomSheet({super.key, required this.video});

  final Video video;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final config = ref.read(testConfigProvider);
    return Semantics(
      identifier: 'detail_bottom_sheet',
      container: true,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(video.title, style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 8),
            Text(
              video.description,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 12),
            Semantics(
              identifier: 'detail_video_url',
              child: Text(video.youtubeUrl),
            ),
            const SizedBox(height: 16),
            Semantics(
              identifier: 'detail_open_youtube_button',
              button: true,
              container: true,
              child: ElevatedButton.icon(
                onPressed: () => ref
                    .read(externalLinkNotifierProvider.notifier)
                    .open(
                      video.youtubeUrl,
                      captureExternalLinks: config.captureExternalLinks,
                    ),
                icon: const Icon(Icons.open_in_new),
                label: const Text('Open in YouTube'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
