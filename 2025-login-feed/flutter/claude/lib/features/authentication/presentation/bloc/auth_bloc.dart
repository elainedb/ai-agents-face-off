import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/usecases/usecase.dart';
import '../../domain/usecases/get_current_user.dart';
import '../../domain/usecases/sign_in_with_google.dart' as usecases;
import '../../domain/usecases/sign_out.dart' as usecases;
import 'auth_event.dart';
import 'auth_state.dart';

@injectable
class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final usecases.SignInWithGoogle _signInWithGoogle;
  final usecases.SignOut _signOut;
  final GetCurrentUser _getCurrentUser;

  AuthBloc(
    this._signInWithGoogle,
    this._signOut,
    this._getCurrentUser,
  ) : super(const AuthState.initial()) {
    on<SignInWithGoogle>(_onSignInWithGoogle);
    on<SignOut>(_onSignOut);
    on<CheckAuthStatus>(_onCheckAuthStatus);
  }

  Future<void> _onSignInWithGoogle(
    SignInWithGoogle event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthState.loading());

    final result = await _signInWithGoogle(NoParams());

    result.fold(
      (failure) => emit(AuthState.error(failure.message)),
      (user) => emit(AuthState.authenticated(user)),
    );
  }

  Future<void> _onSignOut(
    SignOut event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthState.loading());

    final result = await _signOut(NoParams());

    result.fold(
      (failure) => emit(AuthState.error(failure.message)),
      (_) => emit(const AuthState.unauthenticated()),
    );
  }

  Future<void> _onCheckAuthStatus(
    CheckAuthStatus event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthState.loading());

    final result = await _getCurrentUser(NoParams());

    result.fold(
      (failure) => emit(AuthState.error(failure.message)),
      (user) => user != null
          ? emit(AuthState.authenticated(user))
          : emit(const AuthState.unauthenticated()),
    );
  }
}