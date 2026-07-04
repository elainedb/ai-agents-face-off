import 'package:google_sign_in/google_sign_in.dart';
import '../test_config.dart';

class AuthResult {
  final bool success;
  final String? error;
  final String? email;

  AuthResult({required this.success, this.error, this.email});
}

class AuthRepository {
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: ['email'],
  );

  String? _currentUserEmail;
  String? get currentUserEmail => _currentUserEmail;

  Future<AuthResult> signIn() async {
    try {
      final config = TestConfig.instance;
      String? email;

      if (config.uiTestMode && config.mockAuthEmail != null) {
        email = config.mockAuthEmail;
      } else {
        // Real Google Sign-In
        final account = await _googleSignIn.signIn();
        if (account == null) {
          return AuthResult(success: false, error: 'Sign in aborted');
        }
        email = account.email;
      }

      if (email == null) {
         return AuthResult(success: false, error: 'No email found');
      }

      // Check whitelist
      final whitelistStr = config.authorizedEmails ?? 'user1@example.com,user2@example.com';
      final whitelist = whitelistStr.split(',').map((e) => e.trim()).toList();

      if (!whitelist.contains(email)) {
        await signOut();
        return AuthResult(success: false, error: 'Unauthorized email');
      }

      _currentUserEmail = email;
      return AuthResult(success: true, email: email);

    } catch (e) {
      return AuthResult(success: false, error: e.toString());
    }
  }

  Future<void> signOut() async {
    _currentUserEmail = null;
    if (!TestConfig.instance.uiTestMode || TestConfig.instance.mockAuthEmail == null) {
      try {
        await _googleSignIn.signOut();
      } catch (_) {}
    }
  }
}
