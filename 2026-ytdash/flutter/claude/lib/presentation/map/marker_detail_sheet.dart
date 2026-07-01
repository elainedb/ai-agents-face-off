import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/external_launch.dart';
import '../../domain/entities/video.dart';

/// The detail panel shown after tapping a `map_marker`. Rendered as a plain in-tree overlay (not
/// a `showModalBottomSheet` route) — Flutter routes share the semantics tree either way, but an
/// inline overlay is the simplest way to guarantee `detail_bottom_sheet` and its children stay
/// reachable (constitution §5a).
class MarkerDetailSheet extends ConsumerWidget {
  const MarkerDetailSheet({
    super.key,
    required this.video,
    required this.onClose,
  });

  final Video video;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Semantics(
      container: true,
      identifier: 'detail_bottom_sheet',
      child: Material(
        elevation: 8,
        color: Theme.of(context).colorScheme.surface,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      video.title,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                  IconButton(icon: const Icon(Icons.close), onPressed: onClose),
                ],
              ),
              const SizedBox(height: 4),
              Semantics(
                container: true,
                identifier: 'detail_video_url',
                child: Text(
                  video.youtubeUrl,
                  style: const TextStyle(color: Colors.blueGrey),
                ),
              ),
              const SizedBox(height: 12),
              Semantics(
                container: true,
                identifier: 'detail_open_youtube_button',
                button: true,
                child: ElevatedButton.icon(
                  onPressed: () => ref
                      .read(externalLaunchProvider.notifier)
                      .open(video.youtubeUrl),
                  icon: const Icon(Icons.open_in_new),
                  label: const Text('Open in YouTube'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
