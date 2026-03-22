import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../../domain/entities/user.dart';
import '../../domain/usecases/get_current_user.dart';
import '../../domain/usecases/sign_in_with_google.dart';
import '../../domain/usecases/sign_out.dart';

part 'auth_bloc.freezed.dart';

@freezed
class AuthEvent with _$AuthEvent {
  const factory AuthEvent.signInWithGoogle() = _SignInWithGoogle;
  const factory AuthEvent.signOut() = _SignOut;
  const factory AuthEvent.checkAuthStatus() = _CheckAuthStatus;
}

@freezed
class AuthState with _$AuthState {
  const factory AuthState.initial() = _Initial;
  const factory AuthState.loading() = _Loading;
  const factory AuthState.authenticated(User user) = _Authenticated;
  const factory AuthState.unauthenticated() = _Unauthenticated;
  const factory AuthState.error(String message) = _Error;
}

@injectable
class AuthBloc extends Bloc<AuthEvent, AuthState> {
  AuthBloc(this._signInWithGoogle, this._signOut, this._getCurrentUser)
    : super(const AuthState.initial()) {
    on<_CheckAuthStatus>(_onCheckAuthStatus);
    on<_SignInWithGoogle>(_onSignInWithGoogle);
    on<_SignOut>(_onSignOut);
  }

  final SignInWithGoogle _signInWithGoogle;
  final SignOut _signOut;
  final GetCurrentUser _getCurrentUser;

  Future<void> _onCheckAuthStatus(
    _CheckAuthStatus event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthState.loading());
    final result = await _getCurrentUser(const NoParams());
    emit(
      result.fold(
        _mapFailureToState,
        (user) => user == null
            ? const AuthState.unauthenticated()
            : AuthState.authenticated(user),
      ),
    );
  }

  Future<void> _onSignInWithGoogle(
    _SignInWithGoogle event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthState.loading());
    final result = await _signInWithGoogle(const NoParams());
    emit(result.fold(_mapFailureToState, AuthState.authenticated));
  }

  Future<void> _onSignOut(_SignOut event, Emitter<AuthState> emit) async {
    await _signOut(const NoParams());
    emit(const AuthState.unauthenticated());
  }

  AuthState _mapFailureToState(Failure failure) {
    return AuthState.error(failure.message);
  }
}
