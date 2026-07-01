import 'package:google_sign_in/google_sign_in.dart';

import '../core/test_config.dart';

/// The production whitelist used when no `authorizedEmails` launch extra overrides it
/// (constitution §4: `authorizedEmails` overrides the whitelist for the run).
const defaultAuthorizedEmails = [
  'user1@example.com',
  'user2@example.com',
];

/// Wraps the non-deterministic edge (the real Google account picker) so the domain/presentation
/// layers only ever see "an email came back, or sign-in failed" (constitution §4).
class AuthRepository {
  final GoogleSignIn _googleSignIn = GoogleSignIn.instance;
  bool _initialized = false;

  Future<String> signIn(TestConfig config) async {
    if (config.uiTestMode) {
      final mockEmail = config.mockAuthEmail;
      if (mockEmail == null || mockEmail.isEmpty) {
        throw StateError(
          'uiTestMode is on but mockAuthEmail was not provided.',
        );
      }
      return mockEmail;
    }
    if (!_initialized) {
      await _googleSignIn.initialize();
      _initialized = true;
    }
    if (!_googleSignIn.supportsAuthenticate()) {
      throw UnsupportedError(
        'This platform requires a platform-specific sign-in UI.',
      );
    }
    final account = await _googleSignIn.authenticate();
    return account.email;
  }

  Future<void> signOut(TestConfig config) async {
    if (config.uiTestMode) return;
    if (_initialized) {
      await _googleSignIn.signOut();
    }
  }

  List<String> whitelistFor(TestConfig config) {
    final overridden = config.authorizedEmailList;
    return overridden.isNotEmpty ? overridden : defaultAuthorizedEmails;
  }
}
