import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:ytdash_flutter/data/models/test_config.dart';
import 'package:ytdash_flutter/data/repositories/preference_repository.dart';

class AuthViewModel extends ChangeNotifier {
  final PreferenceRepository _prefRepository;
  final GoogleSignIn _googleSignIn = GoogleSignIn(scopes: ['email']);

  String? _currentUserEmail;
  String? get currentUserEmail => _currentUserEmail;

  bool _isLoggingIn = false;
  bool get isLoggingIn => _isLoggingIn;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  bool get isAuthenticated => _currentUserEmail != null;

  static const List<String> defaultWhitelist = [
    'user1@example.com',
    'user2@example.com',
  ];

  AuthViewModel({required PreferenceRepository prefRepository})
      : _prefRepository = prefRepository;

  Future<void> init() async {
    // In compliance with the E2E test flows (e.g., AC-CACHE-01) which expect
    // 'login_google_button' to be visible upon a fresh relaunch of the app with
    // clearState: false, we do not automatically log the user back in at startup.
    _currentUserEmail = null;
    notifyListeners();
  }

  Future<bool> login(TestConfig testConfig) async {
    _isLoggingIn = true;
    _errorMessage = null;
    notifyListeners();

    try {
      String? email;

      if (testConfig.uiTestMode) {
        // Test mode bypass
        email = testConfig.mockAuthEmail;
        if (email == null || email.isEmpty) {
          _errorMessage = 'No mock auth email provided in test mode';
          _isLoggingIn = false;
          notifyListeners();
          return false;
        }
      } else {
        // Real Google Sign-In
        try {
          final account = await _googleSignIn.signIn();
          email = account?.email;
        } catch (e) {
          _errorMessage = 'Google Sign-In failed: $e';
          _isLoggingIn = false;
          notifyListeners();
          return false;
        }
      }

      if (email == null) {
        _errorMessage = 'Sign-in cancelled';
        _isLoggingIn = false;
        notifyListeners();
        return false;
      }

      // Whitelist check
      final whitelist = testConfig.getWhitelistedEmails(defaultWhitelist);
      final isAuthorized = whitelist.any((e) => e.toLowerCase() == email!.toLowerCase());

      if (isAuthorized) {
        await _prefRepository.saveUserEmail(email);
        _currentUserEmail = email;
        _errorMessage = null;
        _isLoggingIn = false;
        notifyListeners();
        return true;
      } else {
        _errorMessage = 'Access denied: email is not authorized.';
        _isLoggingIn = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _errorMessage = 'An unexpected error occurred during login: $e';
      _isLoggingIn = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> logout(TestConfig testConfig) async {
    await _prefRepository.clearSession();
    _currentUserEmail = null;
    _errorMessage = null;
    notifyListeners();

    if (!testConfig.uiTestMode) {
      try {
        await _googleSignIn.signOut();
      } catch (_) {
        // Ignore signout exceptions
      }
    }
  }
}
