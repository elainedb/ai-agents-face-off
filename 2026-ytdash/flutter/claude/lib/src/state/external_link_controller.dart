import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

import 'providers.dart';

/// App-root state for "open in YouTube". Lifted above both the list and the
/// map sheet so a single banner serves both (cross-framework-setup §C).
///
/// Under `captureExternalLinks=true` the target URL is captured and surfaced
/// (deterministic check) instead of launched. Otherwise a real external launch
/// is attempted; on failure [errorUrl] is set so the app surfaces
/// `external_open_error` rather than crashing/no-op'ing (constitution §4).
class ExternalLinkState {
  const ExternalLinkState({this.capturedUrl, this.errorUrl});

  /// The URL surfaced for the harness when capturing (text == URL).
  final String? capturedUrl;

  /// Set when a real launch was attempted and failed.
  final String? errorUrl;

  bool get hasError => errorUrl != null;
}

class ExternalLinkController extends Notifier<ExternalLinkState> {
  @override
  ExternalLinkState build() => const ExternalLinkState();

  Future<void> open(String url) async {
    final capture = ref.read(testConfigProvider).captureExternalLinks;
    if (capture) {
      state = ExternalLinkState(capturedUrl: url);
      return;
    }
    state = const ExternalLinkState();
    try {
      final ok = await launchUrl(
        Uri.parse(url),
        mode: LaunchMode.externalApplication,
      );
      if (!ok) {
        state = ExternalLinkState(errorUrl: url);
      }
    } catch (_) {
      state = ExternalLinkState(errorUrl: url);
    }
  }

  void clear() => state = const ExternalLinkState();
}
