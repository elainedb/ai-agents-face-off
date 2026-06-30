import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../external_open_controller.dart';
import 'test_id.dart';

/// App-root overlay that renders the captured external URL (`external_open_url`) or a real-launch
/// failure (`external_open_error`). Lifted above the Navigator so the SAME surface serves both the
/// list and the map bottom sheet (cross-framework-setup §C).
class ExternalOpenBanner extends StatelessWidget {
  const ExternalOpenBanner({super.key});

  @override
  Widget build(BuildContext context) {
    final ext = context.watch<ExternalOpenController>();
    final url = ext.capturedUrl;
    final error = ext.launchError;
    if (url == null && !error) return const SizedBox.shrink();

    return Positioned(
      left: 0,
      right: 0,
      bottom: 0,
      child: SafeArea(
        child: Material(
          color: error ? Colors.red.shade700 : Colors.black87,
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Expanded(
                  child: error
                      ? const TestId(
                          'external_open_error',
                          child: Text(
                            'Could not open the link externally.',
                            style: TextStyle(color: Colors.white),
                          ),
                        )
                      : TestId(
                          'external_open_url',
                          // Text is EXACTLY the URL so the harness can compare it byte-for-byte
                          // against the marker's detail_video_url (AC-MAP-03 / AC-LIST-03).
                          child: Text(
                            url!,
                            style: const TextStyle(color: Colors.white),
                          ),
                        ),
                ),
                TextButton(
                  onPressed: () => context.read<ExternalOpenController>().clear(),
                  child: const Text('Dismiss', style: TextStyle(color: Colors.white)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
