import 'package:equatable/equatable.dart';

abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object?> get props => [];
}

class SignInWithGoogleRequested extends AuthEvent {
  const SignInWithGoogleRequested();
}

class SignOutRequested extends AuthEvent {
  const SignOutRequested();
}

class CheckAuthStatusRequested extends AuthEvent {
  const CheckAuthStatusRequested();
}
