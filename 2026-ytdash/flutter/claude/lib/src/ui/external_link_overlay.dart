import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../state/providers.dart';
import 'identified.dart';

/// App-root overlay that renders the captured external URL (`external_open_url`)
/// or the external-open error (`external_open_error`). Mounted above every route
/// via `MaterialApp.builder` so the same banner serves the list and the map.
class ExternalLinkOverlay extends ConsumerWidget {
  const ExternalLinkOverlay({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(externalLinkControllerProvider);
    final children = <Widget>[];

    if (state.capturedUrl != null) {
      children.add(_banner(
        context: context,
        color: Colors.green.shade700,
        child: Identified(
          'external_open_url',
          label: state.capturedUrl,
          child: Text(
            state.capturedUrl!,
            style: const TextStyle(color: Colors.white),
          ),
        ),
        onClose: () => ref.read(externalLinkControllerProvider.notifier).clear(),
      ));
    }

    if (state.hasError) {
      children.add(_banner(
        context: context,
        color: Colors.red.shade700,
        child: Identified(
          'external_open_error',
          label: 'Could not open ${state.errorUrl}',
          child: Text(
            'Could not open the link. Please try again.',
            style: const TextStyle(color: Colors.white),
          ),
        ),
        onClose: () => ref.read(externalLinkControllerProvider.notifier).clear(),
      ));
    }

    if (children.isEmpty) return const SizedBox.shrink();

    return Positioned(
      top: MediaQuery.of(context).padding.top + 8,
      left: 8,
      right: 8,
      child: Column(mainAxisSize: MainAxisSize.min, children: children),
    );
  }

  Widget _banner({
    required BuildContext context,
    required Color color,
    required Widget child,
    required VoidCallback onClose,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Material(
        color: color,
        borderRadius: BorderRadius.circular(8),
        elevation: 6,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          child: Row(
            children: [
              Expanded(child: child),
              IconButton(
                icon: const Icon(Icons.close, color: Colors.white, size: 18),
                onPressed: onClose,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
