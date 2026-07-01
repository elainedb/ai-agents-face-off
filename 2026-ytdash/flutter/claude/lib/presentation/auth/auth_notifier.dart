import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/providers.dart';
import '../../domain/auth/auth_service.dart';
import '../../domain/auth/auth_state.dart';

class AuthNotifier extends Notifier<AuthState> {
  @override
  AuthState build() => const AuthSignedOut();

  Future<void> signIn() async {
    state = const AuthInProgress();
    final config = ref.read(testConfigProvider);
    final authRepo = ref.read(authRepositoryProvider);
    try {
      final email = await authRepo.signIn(config);
      final whitelist = authRepo.whitelistFor(config);
      if (isAuthorizedEmail(email, whitelist)) {
        state = AuthSignedIn(email);
      } else {
        // Don't leave a real Google session signed in when access is denied.
        await authRepo.signOut(config);
        state = AuthDenied(email);
      }
    } catch (e) {
      state = AuthError(e.toString());
    }
  }

  Future<void> signOut() async {
    final config = ref.read(testConfigProvider);
    final authRepo = ref.read(authRepositoryProvider);
    await authRepo.signOut(config);
    state = const AuthSignedOut();
  }
}

final authNotifierProvider = NotifierProvider<AuthNotifier, AuthState>(
  AuthNotifier.new,
);
