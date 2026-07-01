/// Unidirectional, observable auth view-state (constitution §1.3).
sealed class AuthState {
  const AuthState();
}

class AuthSignedOut extends AuthState {
  const AuthSignedOut();
}

class AuthInProgress extends AuthState {
  const AuthInProgress();
}

class AuthSignedIn extends AuthState {
  const AuthSignedIn(this.email);
  final String email;
}

/// A sign-in attempt that succeeded with Google but whose email isn't on the whitelist.
class AuthDenied extends AuthState {
  const AuthDenied(this.email);
  final String email;
}

/// Sign-in itself failed (network, cancelled, plugin error) — distinct from a whitelist denial.
class AuthError extends AuthState {
  const AuthError(this.message);
  final String message;
}
