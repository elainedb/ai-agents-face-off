import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:ytdash_flutter_claude/core/usecases/usecase.dart';
import 'package:ytdash_flutter_claude/features/authentication/domain/usecases/get_current_user.dart';
import 'package:ytdash_flutter_claude/features/authentication/domain/usecases/sign_in_with_google.dart';
import 'package:ytdash_flutter_claude/features/authentication/domain/usecases/sign_out.dart';
import 'package:ytdash_flutter_claude/features/authentication/presentation/bloc/auth_event.dart';
import 'package:ytdash_flutter_claude/features/authentication/presentation/bloc/auth_state.dart';

@injectable
class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final SignInWithGoogle _signInWithGoogle;
  final SignOut _signOut;
  final GetCurrentUser _getCurrentUser;

  AuthBloc({
    required SignInWithGoogle signInWithGoogle,
    required SignOut signOut,
    required GetCurrentUser getCurrentUser,
  })  : _signInWithGoogle = signInWithGoogle,
        _signOut = signOut,
        _getCurrentUser = getCurrentUser,
        super(const AuthState.initial()) {
    on<AuthEvent>((event, emit) async {
      await event.when(
        signInWithGoogle: () => _onSignInWithGoogle(emit),
        signOut: () => _onSignOut(emit),
        checkAuthStatus: () => _onCheckAuthStatus(emit),
      );
    });
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
    await _signOut(const NoParams());
    emit(const AuthState.unauthenticated());
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
}
