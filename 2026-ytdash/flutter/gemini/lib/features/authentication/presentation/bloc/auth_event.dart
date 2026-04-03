import 'package:freezed_annotation/freezed_annotation.dart';

part 'auth_event.freezed.dart';

@freezed
class AuthEvent with _$AuthEvent {
  const factory AuthEvent.signInWithGoogle() = SignInWithGoogleEvent;
  const factory AuthEvent.signOut() = SignOutEvent;
  const factory AuthEvent.checkAuthStatus() = CheckAuthStatus;
}
