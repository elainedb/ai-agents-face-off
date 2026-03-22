import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:ytdash_flutter_gemini/core/usecases/usecase.dart';
import 'package:ytdash_flutter_gemini/features/authentication/domain/usecases/get_current_user.dart';
import 'package:ytdash_flutter_gemini/features/authentication/domain/usecases/sign_in_with_google.dart';
import 'package:ytdash_flutter_gemini/features/authentication/domain/usecases/sign_out.dart';

import 'auth_event.dart';
import 'auth_state.dart';

@injectable
class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final GetCurrentUser _getCurrentUser;
  final SignInWithGoogle _signInWithGoogle;
  final SignOut _signOut;

  AuthBloc(
    this._getCurrentUser,
    this._signInWithGoogle,
    this._signOut,
  ) : super(const AuthState.initial()) {
    on<AuthEvent>((event, emit) async {
      await event.map(
        checkAuthStatus: (_) async => _onCheckAuthStatus(emit),
        signInWithGoogle: (_) async => _onSignInWithGoogle(emit),
        signOut: (_) async => _onSignOut(emit),
      );
    });
  }

  Future<void> _onCheckAuthStatus(Emitter<AuthState> emit) async {
    final result = await _getCurrentUser(const NoParams());
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

  Future<void> _onSignInWithGoogle(Emitter<AuthState> emit) async {
    emit(const AuthState.loading());
    final result = await _signInWithGoogle(const NoParams());
    result.fold(
      (failure) => emit(AuthState.error(failure.message)),
      (user) => emit(AuthState.authenticated(user)),
    );
  }

  Future<void> _onSignOut(Emitter<AuthState> emit) async {
    emit(const AuthState.loading());
    await _signOut(const NoParams());
    emit(const AuthState.unauthenticated());
  }
}
