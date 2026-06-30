import 'package:flutter/foundation.dart';
import 'package:url_launcher/url_launcher.dart';

import '../core/test_config.dart';

/// Single source for "open in YouTube", lifted to the app root so BOTH the list (iteration 2) and
/// the map bottom sheet (iteration 4) feed the same `external_open_url` / `external_open_error`
/// surface (constitution §4; cross-framework-setup §C).
class ExternalOpenController extends ChangeNotifier {
  ExternalOpenController({required this.config});

  final TestConfig config;

  /// In capture mode, the URL that *would* be opened (text == this is asserted by the harness).
  String? capturedUrl;

  /// Set when a REAL external launch was attempted and failed — surfaced instead of crashing.
  bool launchError = false;

  Future<void> open(String url) async {
    if (config.captureExternalLinks) {
      // Deterministic test path: render the target URL, do not launch.
      capturedUrl = url;
      launchError = false;
      notifyListeners();
      return;
    }

    // Production / real-launch path.
    capturedUrl = null;
    try {
      final ok = await launchUrl(
        Uri.parse(url),
        mode: LaunchMode.externalApplication,
      );
      launchError = !ok;
    } catch (_) {
      launchError = true;
    }
    notifyListeners();
  }

  void clear() {
    capturedUrl = null;
    launchError = false;
    notifyListeners();
  }
}
