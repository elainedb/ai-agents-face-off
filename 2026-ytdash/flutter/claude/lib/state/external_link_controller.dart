import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

import '../core/test_config.dart';
import 'providers.dart';

enum ExternalLinkStatus { idle, captured, error }

@immutable
class ExternalLinkState {
  const ExternalLinkState({required this.status, this.url, this.errorMessage});

  final ExternalLinkStatus status;
  final String? url;
  final String? errorMessage;

  static const idle = ExternalLinkState(status: ExternalLinkStatus.idle);
}

/// Lifted to the app root (not per-screen) — the same "open in YouTube" banner serves both the
/// video list and the map's detail sheet, per cross-framework-setup.md's guidance.
class ExternalLinkController extends Notifier<ExternalLinkState> {
  TestConfig get testConfig => ref.read(testConfigProvider);

  @override
  ExternalLinkState build() => ExternalLinkState.idle;

  /// Constitution §4: with `captureExternalLinks=true` the app must NOT actually launch anything —
  /// it renders `external_open_url` with the target URL as text (deterministic check). Otherwise it
  /// performs the real external launch and surfaces `external_open_error` on failure instead of
  /// crashing or silently doing nothing.
  Future<void> open(String url) async {
    if (testConfig.captureExternalLinks) {
      state = ExternalLinkState(status: ExternalLinkStatus.captured, url: url);
      return;
    }
    try {
      final uri = Uri.parse(url);
      final launched = await launchUrl(
        uri,
        mode: LaunchMode.externalApplication,
      );
      if (!launched) {
        state = ExternalLinkState(
          status: ExternalLinkStatus.error,
          errorMessage: 'Could not open $url',
        );
        return;
      }
      state = ExternalLinkState.idle;
    } catch (e) {
      state = ExternalLinkState(
        status: ExternalLinkStatus.error,
        errorMessage: 'Could not open $url: $e',
      );
    }
  }

  void dismiss() => state = ExternalLinkState.idle;
}
