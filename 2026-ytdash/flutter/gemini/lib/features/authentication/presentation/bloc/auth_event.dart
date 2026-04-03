part of 'auth_bloc.dart';

@freezed
class AuthEvent with _$AuthEvent {
  const factory AuthEvent.checkAuthStatus() = _CheckAuthStatus;
  const factory AuthEvent.signInWithGoogle() = _SignInWithGoogleEvent;
  const factory AuthEvent.signOut() = _SignOutEvent;
}
