import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'test_config.dart';

enum AuthStatus { unauthenticated, authenticating, authenticated, unauthorizedError, failureError }

class AuthService extends ChangeNotifier {
  final TestConfig config;
  final GoogleSignIn _googleSignIn = GoogleSignIn(scopes: ['email']);

  AuthStatus _status = AuthStatus.unauthenticated;
  String? _currentUserEmail;
  String? _errorMessage;

  AuthService({required this.config});

  AuthStatus get status => _status;
  String? get currentUserEmail => _currentUserEmail;
  String? get errorMessage => _errorMessage;

  bool get isAuthenticated => _status == AuthStatus.authenticated;

  Future<void> login() async {
    _status = AuthStatus.authenticating;
    _errorMessage = null;
    notifyListeners();

    try {
      String? email;

      if (config.uiTestMode) {
        // Mock Mode / UI Test Mode
        email = config.mockAuthEmail;
        if (email == null || email.isEmpty) {
          _status = AuthStatus.failureError;
          _errorMessage = "No mock authentication email supplied in test mode.";
          notifyListeners();
          return;
        }
      } else {
        // Real Google Sign In Mode
        try {
          final GoogleSignInAccount? account = await _googleSignIn.signIn();
          email = account?.email;
          if (email == null) {
            _status = AuthStatus.unauthenticated;
            notifyListeners();
            return;
          }
        } catch (e) {
          _status = AuthStatus.failureError;
          _errorMessage = "Google Sign-In failed: $e";
          notifyListeners();
          return;
        }
      }

      // Check Whitelist
      final isAuthorized = config.authorizedEmails.any(
        (authorized) => authorized.toLowerCase().trim() == email!.toLowerCase().trim()
      );

      if (isAuthorized) {
        _currentUserEmail = email;
        _status = AuthStatus.authenticated;
      } else {
        // Unauthorized
        _currentUserEmail = email;
        _status = AuthStatus.unauthorizedError;
        _errorMessage = "Email $email is not authorized.";
        if (!config.uiTestMode) {
          await _googleSignIn.signOut();
        }
      }
    } catch (e) {
      _status = AuthStatus.failureError;
      _errorMessage = "An unexpected auth error occurred: $e";
    }

    notifyListeners();
  }

  Future<void> logout() async {
    _status = AuthStatus.unauthenticated;
    _currentUserEmail = null;
    _errorMessage = null;
    if (!config.uiTestMode) {
      try {
        await _googleSignIn.signOut();
      } catch (e) {
        print('Error signing out of Google: $e');
      }
    }
    notifyListeners();
  }
}
