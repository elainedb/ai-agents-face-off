import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../state/external_link_controller.dart';
import '../state/providers.dart';

/// App-root banner (constitution §3/§4): renders `external_open_url` (capture mode) or
/// `external_open_error` (a failed real launch) above whatever screen is currently visible, so the
/// same widget serves both the video list and the map's detail sheet.
class ExternalLinkBanner extends ConsumerWidget {
  const ExternalLinkBanner({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final linkState = ref.watch(externalLinkControllerProvider);
    if (linkState.status == ExternalLinkStatus.idle) {
      return const SizedBox.shrink();
    }
    final isError = linkState.status == ExternalLinkStatus.error;
    return SafeArea(
      child: Material(
        color: isError ? Colors.red.shade700 : Colors.black87,
        child: InkWell(
          onTap: () =>
              ref.read(externalLinkControllerProvider.notifier).dismiss(),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: Semantics(
              identifier: isError ? 'external_open_error' : 'external_open_url',
              child: Text(
                isError
                    ? (linkState.errorMessage ?? 'Could not open link')
                    : (linkState.url ?? ''),
                style: const TextStyle(color: Colors.white),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
