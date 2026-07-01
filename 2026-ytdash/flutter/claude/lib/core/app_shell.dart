import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../presentation/external_link/external_link_notifier.dart';
import '../presentation/external_link/external_link_state.dart';

/// Root shell hosting the external-link banner above whatever screen is current, shared by the
/// video list (iteration 2) and the map detail sheet (iteration 4) — see
/// cross-framework-setup.md §C.
class AppShell extends ConsumerWidget {
  const AppShell({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final linkState = ref.watch(externalLinkNotifierProvider);
    return Stack(
      children: [
        child,
        if (linkState is ExternalLinkCaptured ||
            linkState is ExternalLinkFailed)
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: SafeArea(
              child: Material(
                color: linkState is ExternalLinkFailed
                    ? Colors.red.shade700
                    : Colors.black87,
                child: InkWell(
                  onTap: () =>
                      ref.read(externalLinkNotifierProvider.notifier).dismiss(),
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: switch (linkState) {
                      ExternalLinkCaptured(:final url) => Semantics(
                        identifier: 'external_open_url',
                        container: true,
                        child: Text(
                          url,
                          style: const TextStyle(color: Colors.white),
                        ),
                      ),
                      ExternalLinkFailed() => Semantics(
                        identifier: 'external_open_error',
                        container: true,
                        child: const Text(
                          'Could not open the link externally.',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                      _ => const SizedBox.shrink(),
                    },
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}
