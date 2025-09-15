
part of 'login_bloc.dart';

@freezed
class LoginEvent with _$LoginEvent {
  const factory LoginEvent.signInWithGoogle() = _SignInWithGoogle;
const factory LoginEvent.signOut() = _SignOut;
}
