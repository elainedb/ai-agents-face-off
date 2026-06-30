import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/auth_service.dart';
import '../domain/auth_policy.dart';
import 'providers.dart';

enum AuthStatus { signedOut, signingIn, signedIn, error }

/// Observable auth view-state (constitution §1.3). [error] is set when a
/// signed-in account is not on the whitelist or sign-in fails.
class AuthState {
  const AuthState({
    this.status = AuthStatus.signedOut,
    this.email,
    this.errorMessage,
  });

  final AuthStatus status;
  final String? email;
  final String? errorMessage;

  bool get isSignedIn => status == AuthStatus.signedIn;

  AuthState copyWith({
    AuthStatus? status,
    String? email,
    String? errorMessage,
  }) =>
      AuthState(
        status: status ?? this.status,
        email: email ?? this.email,
        errorMessage: errorMessage,
      );
}

class AuthController extends Notifier<AuthState> {
  @override
  AuthState build() => const AuthState();

  AuthService get _service => ref.read(authServiceProvider);
  AuthPolicy get _policy => ref.read(authPolicyProvider);

  Future<void> signIn() async {
    state = const AuthState(status: AuthStatus.signingIn);
    try {
      final email = await _service.signIn();
      if (!_policy.isAuthorized(email)) {
        state = AuthState(
          status: AuthStatus.error,
          email: email,
          errorMessage: 'Account $email is not authorized to use this app.',
        );
        return;
      }
      state = AuthState(status: AuthStatus.signedIn, email: email);
    } catch (e) {
      state = AuthState(
        status: AuthStatus.error,
        errorMessage: 'Sign-in failed. Please try again.',
      );
    }
  }

  Future<void> signOut() async {
    await _service.signOut();
    state = const AuthState();
  }
}
