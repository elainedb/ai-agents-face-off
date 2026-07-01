import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

import 'app_config.dart';

/// The result of the most recent attempt to open a video externally. Lifted to the app root
/// (rather than per-screen) so the same banner serves both the list (iteration 2) and the map
/// bottom sheet (iteration 4) without duplicating state, per cross-framework-setup guidance.
class ExternalLaunchState {
  const ExternalLaunchState({this.capturedUrl, this.hasError = false});

  final String? capturedUrl;
  final bool hasError;
}

class ExternalLaunchController extends StateNotifier<ExternalLaunchState> {
  ExternalLaunchController(this._ref) : super(const ExternalLaunchState());

  final Ref _ref;

  /// Opens [url]. In UI test mode with `captureExternalLinks=true`, deterministically records the
  /// url instead of launching (constitution §4). Otherwise performs the real external launch; a
  /// throw or a `false` result surfaces as an error rather than crashing or silently doing nothing
  /// (constitution §1.6).
  Future<void> open(String url) async {
    final config = _ref.read(appConfigProvider);
    state = const ExternalLaunchState();
    if (config.captureExternalLinks) {
      state = ExternalLaunchState(capturedUrl: url);
      return;
    }
    try {
      final uri = Uri.parse(url);
      final launched = await launchUrl(
        uri,
        mode: LaunchMode.externalApplication,
      );
      state = launched
          ? ExternalLaunchState(capturedUrl: url)
          : const ExternalLaunchState(hasError: true);
    } catch (_) {
      state = const ExternalLaunchState(hasError: true);
    }
  }

  void clear() => state = const ExternalLaunchState();
}

final externalLaunchProvider =
    StateNotifierProvider<ExternalLaunchController, ExternalLaunchState>(
      (ref) => ExternalLaunchController(ref),
    );
