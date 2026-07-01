import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/external_launch.dart';

/// Renders `external_open_url`/`external_open_error` above the entire Navigator (wired via
/// `MaterialApp.builder`), so the same banner is visible regardless of which route is on top —
/// both the list (iteration 2, root route) and the map's marker sheet (iteration 4, a pushed
/// route) share it without duplicating state, per cross-framework-setup.md.
class ExternalLaunchBanner extends ConsumerWidget {
  const ExternalLaunchBanner({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final launchState = ref.watch(externalLaunchProvider);

    Widget banner = const SizedBox.shrink();
    if (launchState.capturedUrl != null) {
      banner = Semantics(
        container: true,
        identifier: 'external_open_url',
        child: Material(
          color: Colors.black87,
          borderRadius: BorderRadius.circular(8),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Text(
              launchState.capturedUrl!,
              style: const TextStyle(color: Colors.white),
            ),
          ),
        ),
      );
    } else if (launchState.hasError) {
      banner = Semantics(
        container: true,
        identifier: 'external_open_error',
        child: Material(
          color: Colors.red.shade700,
          borderRadius: BorderRadius.circular(8),
          child: const Padding(
            padding: EdgeInsets.all(12),
            child: Text(
              'Could not open the video externally.',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ),
      );
    }

    return IgnorePointer(
      child: Align(
        alignment: Alignment.bottomCenter,
        child: Padding(
          padding: const EdgeInsets.only(left: 16, right: 16, bottom: 24),
          child: banner,
        ),
      ),
    );
  }
}
