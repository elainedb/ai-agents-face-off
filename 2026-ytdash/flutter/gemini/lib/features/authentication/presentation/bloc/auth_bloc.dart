import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/usecases/usecase.dart';
import '../../domain/entities/user.dart';
import '../../domain/usecases/get_current_user.dart';
import '../../domain/usecases/sign_in_with_google.dart';
import '../../domain/usecases/sign_out.dart';

part 'auth_event.dart';
part 'auth_state.dart';
part 'auth_bloc.freezed.dart';

@injectable
class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final SignInWithGoogle _signInWithGoogle;
  final SignOut _signOut;
  final GetCurrentUser _getCurrentUser;

  AuthBloc(
    this._signInWithGoogle,
    this._signOut,
    this._getCurrentUser,
  ) : super(const AuthState.initial()) {
    on<CheckAuthStatus>(_onCheckAuthStatus);
    on<SignInWithGoogleEvent>(_onSignInWithGoogle);
    on<SignOutEvent>(_onSignOut);
  }

  Future<void> _onCheckAuthStatus(CheckAuthStatus event, Emitter<AuthState> emit) async {
    final result = await _getCurrentUser(NoParams());
    result.fold(
      (failure) => emit(const AuthState.unauthenticated()),
      (user) {
        if (user != null) {
          emit(AuthState.authenticated(user));
        } else {
          emit(const AuthState.unauthenticated());
        }
      },
    );
  }

  Future<void> _onSignInWithGoogle(SignInWithGoogleEvent event, Emitter<AuthState> emit) async {
    emit(const AuthState.loading());
    final result = await _signInWithGoogle(NoParams());
    result.fold(
      (failure) => emit(AuthState.error(failure.message)),
      (user) => emit(AuthState.authenticated(user)),
    );
  }

  Future<void> _onSignOut(SignOutEvent event, Emitter<AuthState> emit) async {
    emit(const AuthState.loading());
    await _signOut(NoParams());
    emit(const AuthState.unauthenticated());
  }
}
