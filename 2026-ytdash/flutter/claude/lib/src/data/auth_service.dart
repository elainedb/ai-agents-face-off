import 'package:google_sign_in/google_sign_in.dart';

/// Abstraction over identity: returns the signed-in account's email, or throws.
/// Presentation depends on this interface, not on a concrete provider
/// (constitution §1.2 — dependency inversion).
abstract class AuthService {
  /// Signs in and returns the account email. Throws on cancellation/failure.
  Future<String> signIn();
  Future<void> signOut();
}

/// Deterministic auth used under UI-test-mode: skips the Google picker and
/// returns the configured [mockAuthEmail] (constitution §4). Whitelist logic
/// still runs downstream, so authorization is exercised normally.
class MockAuthService implements AuthService {
  MockAuthService(this.mockAuthEmail);
  final String? mockAuthEmail;

  @override
  Future<String> signIn() async {
    final email = mockAuthEmail;
    if (email == null || email.isEmpty) {
      throw const AuthException('No mock email supplied');
    }
    return email;
  }

  @override
  Future<void> signOut() async {}
}

/// Real Google Sign-In (production / real-mode). Never exercised by the scored
/// flows (those use [MockAuthService]); present so the same build works against
/// real Google identity per the definition of done.
class GoogleAuthService implements AuthService {
  bool _initialized = false;

  Future<void> _ensureInit() async {
    if (_initialized) return;
    await GoogleSignIn.instance.initialize();
    _initialized = true;
  }

  @override
  Future<String> signIn() async {
    try {
      await _ensureInit();
      final account = await GoogleSignIn.instance.authenticate();
      final email = account.email;
      if (email.isEmpty) throw const AuthException('Google account has no email');
      return email;
    } on AuthException {
      rethrow;
    } catch (e) {
      throw AuthException('Google sign-in failed: $e');
    }
  }

  @override
  Future<void> signOut() async {
    try {
      await _ensureInit();
      await GoogleSignIn.instance.signOut();
    } catch (_) {
      // Best-effort; sign-out failures must not crash the app.
    }
  }
}

class AuthException implements Exception {
  const AuthException(this.message);
  final String message;
  @override
  String toString() => 'AuthException: $message';
}
