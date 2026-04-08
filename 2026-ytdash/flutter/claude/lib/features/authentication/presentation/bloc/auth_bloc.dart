import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:ytdash_flutter_claude/core/usecases/usecase.dart';
import 'package:ytdash_flutter_claude/features/authentication/domain/usecases/get_current_user.dart';
import 'package:ytdash_flutter_claude/features/authentication/domain/usecases/sign_in_with_google.dart'
    as usecase;
import 'package:ytdash_flutter_claude/features/authentication/domain/usecases/sign_out.dart'
    as usecase;
import 'package:ytdash_flutter_claude/features/authentication/presentation/bloc/auth_event.dart';
import 'package:ytdash_flutter_claude/features/authentication/presentation/bloc/auth_state.dart';

@injectable
class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final usecase.SignInWithGoogle _signInWithGoogle;
  final usecase.SignOut _signOut;
  final GetCurrentUser _getCurrentUser;

  AuthBloc(
    this._signInWithGoogle,
    this._signOut,
    this._getCurrentUser,
  ) : super(const AuthState.initial()) {
    on<SignInWithGoogle>(_onSignInWithGoogle);
    on<SignOutEvent>(_onSignOut);
    on<CheckAuthStatus>(_onCheckAuthStatus);
  }

  Future<void> _onCheckAuthStatus(
    CheckAuthStatus event,
    Emitter<AuthState> emit,
  ) async {
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

  Future<void> _onSignInWithGoogle(
    SignInWithGoogle event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthState.loading());
    final result = await _signInWithGoogle(const NoParams());
    result.fold(
      (failure) => emit(AuthState.error(failure.message)),
      (user) => emit(AuthState.authenticated(user)),
    );
  }

  Future<void> _onSignOut(
    SignOutEvent event,
    Emitter<AuthState> emit,
  ) async {
    await _signOut(const NoParams());
    emit(const AuthState.unauthenticated());
  }
}
