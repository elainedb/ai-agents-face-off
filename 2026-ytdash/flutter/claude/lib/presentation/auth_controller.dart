import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../core/test_config.dart';
import '../domain/auth.dart';

/// Drives the login screen state (constitution §1.3 unidirectional, observable view-state).
class AuthController extends ChangeNotifier {
  AuthController({required this.config}) : _policy = AuthPolicy(config.authorizedEmailList);

  final TestConfig config;
  final AuthPolicy _policy;

  String? currentEmail;
  String? errorMessage;
  bool signedIn = false;
  bool busy = false;

  /// Tapping `login_google_button`. In UI test mode with `mockAuthEmail` set, the real account
  /// picker is skipped and we sign in as that email; the normal whitelist logic still runs
  /// (constitution §4). Outside test mode, real Google sign-in is used.
  Future<void> signIn() async {
    busy = true;
    errorMessage = null;
    notifyListeners();

    String? email;
    try {
      if (config.uiTestMode && (config.mockAuthEmail?.isNotEmpty ?? false)) {
        email = config.mockAuthEmail;
      } else {
        final account = await GoogleSignIn().signIn();
        email = account?.email;
      }
    } catch (e) {
      email = null;
    }

    if (email == null) {
      // User cancelled / sign-in failed — stay on login with a visible error.
      signedIn = false;
      errorMessage = 'Sign-in failed. Please try again.';
      busy = false;
      notifyListeners();
      return;
    }

    currentEmail = email;
    if (_policy.isAuthorized(email)) {
      signedIn = true;
      errorMessage = null;
    } else {
      signedIn = false;
      errorMessage = 'Access denied: $email is not an authorized user.';
    }
    busy = false;
    notifyListeners();
  }

  Future<void> signOut() async {
    if (!config.uiTestMode) {
      try {
        await GoogleSignIn().signOut();
      } catch (_) {/* ignore */}
    }
    signedIn = false;
    currentEmail = null;
    errorMessage = null;
    notifyListeners();
  }
}
