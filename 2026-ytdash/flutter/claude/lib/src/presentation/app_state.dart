import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:url_launcher/url_launcher.dart';

import '../config/app_config.dart';
import '../config/test_config.dart';
import '../domain/auth.dart';

/// App-root state (constitution §1.3): authentication + the shared external-link
/// surface. The capture surface lives here (not per-screen) so the list (iter 2)
/// and the map sheet (iter 4) feed ONE `external_open_url` / `external_open_error`
/// banner (cross-framework §C note).
class AppState extends ChangeNotifier {
  AppState(this.config) {
    _authorizedEmails =
        config.authorizedEmails ?? AppConfig.defaultAuthorizedEmails;
  }

  final TestConfig config;
  late final List<String> _authorizedEmails;

  bool _signedIn = false;
  String? _currentEmail;
  String? _loginError;

  // External-link capture surface.
  String? _capturedUrl;
  bool _externalError = false;

  bool get signedIn => _signedIn;
  String? get currentEmail => _currentEmail;
  String? get loginError => _loginError;
  String? get capturedUrl => _capturedUrl;
  bool get externalError => _externalError;
  List<String> get authorizedEmails => _authorizedEmails;

  /// Sign in. In UI-test-mode with `mockAuthEmail` set, the Google account
  /// picker is skipped and we sign in as that email (then the SAME whitelist
  /// logic runs). Otherwise the real Google flow is used.
  Future<void> signIn() async {
    _loginError = null;
    String? email;
    try {
      if (config.uiTestMode && config.mockAuthEmail != null) {
        email = config.mockAuthEmail;
      } else {
        email = await _realGoogleSignIn();
      }
    } catch (e) {
      _loginError = 'Sign-in failed: $e';
      _signedIn = false;
      notifyListeners();
      return;
    }

    if (isAuthorized(email, _authorizedEmails)) {
      _currentEmail = email;
      _signedIn = true;
      _loginError = null;
    } else {
      _signedIn = false;
      _currentEmail = null;
      _loginError = 'Access denied: $email is not authorized.';
    }
    notifyListeners();
  }

  Future<String?> _realGoogleSignIn() async {
    final googleSignIn = GoogleSignIn();
    final account = await googleSignIn.signIn();
    return account?.email;
  }

  Future<void> signOut() async {
    try {
      if (!(config.uiTestMode && config.mockAuthEmail != null)) {
        await GoogleSignIn().signOut();
      }
    } catch (_) {
      // best-effort; we still drop local session
    }
    _signedIn = false;
    _currentEmail = null;
    _loginError = null;
    _capturedUrl = null;
    _externalError = false;
    notifyListeners();
  }

  /// Open a video's external URL. In capture mode we render the target URL
  /// instead of launching (deterministic check). In real mode we launch and, if
  /// that fails, surface `external_open_error` rather than crashing/no-op.
  Future<void> openExternal(String url) async {
    _externalError = false;
    _capturedUrl = null;

    if (config.captureExternalLinks) {
      _capturedUrl = url;
      notifyListeners();
      return;
    }

    try {
      final ok = await launchUrl(
        Uri.parse(url),
        mode: LaunchMode.externalApplication,
      );
      if (!ok) {
        _externalError = true;
      }
    } catch (_) {
      _externalError = true;
    }
    notifyListeners();
  }

  void clearCapture() {
    _capturedUrl = null;
    _externalError = false;
    notifyListeners();
  }
}
