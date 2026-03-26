import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/usecases/usecase.dart';
import '../../domain/usecases/get_current_user.dart';
import '../../domain/usecases/sign_in_with_google.dart';
import '../../domain/usecases/sign_out.dart';
import 'auth_event.dart';
import 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  AuthBloc({
    required this.signInWithGoogle,
    required this.signOut,
    required this.getCurrentUser,
  }) : super(const AuthInitial()) {
    on<CheckAuthStatusRequested>(_onCheckAuthStatus);
    on<SignInWithGoogleRequested>(_onSignInWithGoogle);
    on<SignOutRequested>(_onSignOut);
  }

  final SignInWithGoogle signInWithGoogle;
  final SignOut signOut;
  final GetCurrentUser getCurrentUser;

  Future<void> _onCheckAuthStatus(
    CheckAuthStatusRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());
    final result = await getCurrentUser(const NoParams());
    result.fold(
      (failure) => emit(AuthError(failure.message)),
      (user) => emit(
        user == null ? const AuthUnauthenticated() : AuthAuthenticated(user),
      ),
    );
  }

  Future<void> _onSignInWithGoogle(
    SignInWithGoogleRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());
    final result = await signInWithGoogle(const NoParams());
    result.fold(
      (failure) => emit(AuthError(failure.message)),
      (user) => emit(AuthAuthenticated(user)),
    );
  }

  Future<void> _onSignOut(
    SignOutRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());
    await signOut(const NoParams());
    emit(const AuthUnauthenticated());
  }
}
