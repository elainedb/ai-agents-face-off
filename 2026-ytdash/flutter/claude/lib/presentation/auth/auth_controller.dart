import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../../core/app_config.dart';
import '../../domain/auth/whitelist.dart';

sealed class AuthState {
  const AuthState();
}

/// Signed out. [deniedEmail] is set right after a sign-in attempt whose email failed the
/// whitelist check, so the login screen can show `login_error_message`.
class AuthLoggedOut extends AuthState {
  const AuthLoggedOut({this.deniedEmail});
  final String? deniedEmail;
}

class AuthLoggedIn extends AuthState {
  const AuthLoggedIn(this.email);
  final String email;
}

/// Handles both the UI-test-mode mock sign-in (constitution §4: `mockAuthEmail` skips the real
/// Google account picker) and the real `google_sign_in` flow, then applies the same whitelist
/// check either way.
class AuthController extends StateNotifier<AuthState> {
  AuthController(this._ref) : super(const AuthLoggedOut());

  final Ref _ref;
  GoogleSignIn? _googleSignIn;

  Future<void> signIn() async {
    final config = _ref.read(appConfigProvider);
    final String? email;
    if (config.uiTestMode &&
        config.mockAuthEmail != null &&
        config.mockAuthEmail!.isNotEmpty) {
      email = config.mockAuthEmail;
    } else {
      email = await _signInWithGoogle();
    }
    if (email == null) return; // user cancelled the real picker
    if (isAuthorized(email, config.authorizedEmails)) {
      state = AuthLoggedIn(email);
    } else {
      state = AuthLoggedOut(deniedEmail: email);
    }
  }

  Future<String?> _signInWithGoogle() async {
    try {
      _googleSignIn ??= GoogleSignIn(scopes: const ['email']);
      final account = await _googleSignIn!.signIn();
      return account?.email;
    } catch (_) {
      return null;
    }
  }

  Future<void> signOut() async {
    try {
      await _googleSignIn?.signOut();
    } catch (_) {
      // best-effort; still clear local state below
    }
    state = const AuthLoggedOut();
  }
}

final authControllerProvider = StateNotifierProvider<AuthController, AuthState>(
  (ref) => AuthController(ref),
);
