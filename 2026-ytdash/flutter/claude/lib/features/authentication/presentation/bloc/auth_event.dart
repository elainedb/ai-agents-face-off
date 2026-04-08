import 'package:freezed_annotation/freezed_annotation.dart';

part 'auth_event.freezed.dart';

@freezed
sealed class AuthEvent with _$AuthEvent {
  const factory AuthEvent.signInWithGoogle() = SignInWithGoogle;
  const factory AuthEvent.signOut() = SignOutEvent;
  const factory AuthEvent.checkAuthStatus() = CheckAuthStatus;
}
