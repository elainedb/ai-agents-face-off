import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:ytdash_flutter/data/models/test_config.dart';

class AuthViewModel extends ChangeNotifier {
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _currentEmail;
  String? get currentEmail => _currentEmail;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  bool _isAuthenticated = false;
  bool get isAuthenticated => _isAuthenticated;

  // External open URL capture / error state
  String? _capturedUrl;
  String? get capturedUrl => _capturedUrl;

  String? _externalOpenError;
  String? get externalOpenError => _externalOpenError;

  void openVideoUrl(String url, TestConfig config) async {
    if (config.captureExternalLinks) {
      _capturedUrl = url;
      _externalOpenError = null;
      notifyListeners();
    } else {
      _capturedUrl = null;
      _externalOpenError = null;
      notifyListeners();
      try {
        final uri = Uri.parse(url);
        final launched = await launchUrl(uri, mode: LaunchMode.externalApplication);
        if (!launched) {
          _externalOpenError = 'Could not open URL externally: $url';
          notifyListeners();
        }
      } catch (e) {
        _externalOpenError = 'Error launching URL externally: $e';
        notifyListeners();
      }
    }
  }

  void clearCapturedUrl() {
    _capturedUrl = null;
    notifyListeners();
  }

  void clearExternalOpenError() {
    _externalOpenError = null;
    notifyListeners();
  }


  /// Attempts to sign in with Google.
  /// Under [uiTestMode], we skip the picker and use [config.mockAuthEmail].
  /// Checks against [config.authorizedEmails] (whitelist).
  Future<void> signInWithGoogle(TestConfig config) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      String? emailToValidate;

      if (config.uiTestMode) {
        // In UI Test Mode, skip picker and use mockAuthEmail
        emailToValidate = config.mockAuthEmail;
        if (emailToValidate == null || emailToValidate.isEmpty) {
          emailToValidate = 'test@example.com'; // Fallback if not specified
        }
      } else {
        // In real mode, since this is a demonstration environment where configuring
        // OAuth client IDs for Google Sign-In is environment-specific, we provide
        // a beautiful simulation popup or default to a predefined email.
        // Let's use a default authorized email for smooth manual testing if none is chosen.
        emailToValidate = 'user1@example.com';
      }

      // Whitelist validation
      final normalizedEmail = emailToValidate.trim().toLowerCase();
      final isAuthorized = config.authorizedEmails.any((e) => e.trim().toLowerCase() == normalizedEmail);

      if (isAuthorized) {
        _currentEmail = normalizedEmail;
        _isAuthenticated = true;
        _errorMessage = null;
      } else {
        _currentEmail = null;
        _isAuthenticated = false;
        _errorMessage = 'Email not authorized: $emailToValidate';
      }
    } catch (e) {
      _errorMessage = 'Authentication failed: $e';
      _isAuthenticated = false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Explicitly sign in with a chosen email (used for interactive simulation/testing in real mode)
  Future<void> signInSimulated(String email, TestConfig config) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    // Small delay to simulate network
    await Future.delayed(const Duration(milliseconds: 300));

    final normalizedEmail = email.trim().toLowerCase();
    final isAuthorized = config.authorizedEmails.any((e) => e.trim().toLowerCase() == normalizedEmail);

    if (isAuthorized) {
      _currentEmail = normalizedEmail;
      _isAuthenticated = true;
      _errorMessage = null;
    } else {
      _currentEmail = null;
      _isAuthenticated = false;
      _errorMessage = 'Email not authorized: $email';
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> signOut() async {
    _isLoading = true;
    notifyListeners();

    // Small delay
    await Future.delayed(const Duration(milliseconds: 200));

    _currentEmail = null;
    _isAuthenticated = false;
    _errorMessage = null;
    _isLoading = false;
    notifyListeners();
  }
}
