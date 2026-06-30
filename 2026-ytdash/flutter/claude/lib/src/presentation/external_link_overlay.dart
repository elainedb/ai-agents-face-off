import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'app_state.dart';
import 'widgets/test_id.dart';

/// App-root overlay carrying the shared external-link surface
/// (`external_open_url` in capture mode, `external_open_error` on a failed real
/// launch). Lifted above all routes so the list and the map sheet share it.
class ExternalLinkOverlay extends StatelessWidget {
  const ExternalLinkOverlay({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final url = context.select<AppState, String?>((s) => s.capturedUrl);
    final error = context.select<AppState, bool>((s) => s.externalError);

    return Directionality(
      textDirection: TextDirection.ltr,
      child: Stack(
        children: [
          child,
          if (url != null)
            _Banner(
              color: Colors.black87,
              child: IdText(
                'external_open_url',
                text: url,
                child: Text(
                  url,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.white, fontSize: 13),
                ),
              ),
            ),
          if (error)
            _Banner(
              color: Colors.red.shade700,
              child: IdText(
                'external_open_error',
                text: 'Could not open the link.',
                child: const Text(
                  'Could not open the link.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.white, fontSize: 13),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _Banner extends StatelessWidget {
  const _Banner({required this.color, required this.child});
  final Color color;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: 0,
      right: 0,
      bottom: 0,
      child: SafeArea(
        child: Material(
          color: color,
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: child,
          ),
        ),
      ),
    );
  }
}
