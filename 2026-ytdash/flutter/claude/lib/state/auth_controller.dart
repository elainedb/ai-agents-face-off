import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../core/test_config.dart';
import '../domain/auth/auth_whitelist.dart';
import 'providers.dart';

enum AuthStatus { loggedOut, authenticating, authenticated, unauthorized }

@immutable
class AuthState {
  const AuthState({required this.status, this.email, this.errorMessage});

  final AuthStatus status;
  final String? email;
  final String? errorMessage;

  static const initial = AuthState(status: AuthStatus.loggedOut);

  AuthState copyWith({
    AuthStatus? status,
    String? email,
    String? errorMessage,
  }) => AuthState(
    status: status ?? this.status,
    email: email ?? this.email,
    errorMessage: errorMessage,
  );
}

/// Presentation logic only — the actual whitelist decision is the pure, unit-tested
/// [isAuthorized] function (constitution §1.3: no business logic in UI event handlers).
class AuthController extends Notifier<AuthState> {
  bool _googleInitialized = false;

  TestConfig get testConfig => ref.read(testConfigProvider);

  @override
  AuthState build() => AuthState.initial;

  Future<void> signIn() async {
    state = state.copyWith(status: AuthStatus.authenticating);
    try {
      final email = testConfig.uiTestMode
          ? (testConfig.mockAuthEmail ?? '')
          : await _realGoogleSignIn();
      if (isAuthorized(email, testConfig.authorizedEmails)) {
        state = AuthState(status: AuthStatus.authenticated, email: email);
      } else {
        state = AuthState(
          status: AuthStatus.unauthorized,
          email: email,
          errorMessage: 'This account is not authorized to use this app.',
        );
      }
    } catch (e) {
      state = AuthState(
        status: AuthStatus.unauthorized,
        errorMessage: 'Sign-in failed: $e',
      );
    }
  }

  Future<String> _realGoogleSignIn() async {
    final signIn = GoogleSignIn.instance;
    if (!_googleInitialized) {
      await signIn.initialize();
      _googleInitialized = true;
    }
    if (!signIn.supportsAuthenticate()) {
      throw StateError(
        'Interactive Google sign-in is not supported on this platform.',
      );
    }
    final account = await signIn.authenticate();
    return account.email;
  }

  Future<void> signOut() async {
    if (!testConfig.uiTestMode) {
      try {
        await GoogleSignIn.instance.signOut();
      } catch (_) {
        // best-effort; still clear local state below
      }
    }
    state = AuthState.initial;
  }
}
