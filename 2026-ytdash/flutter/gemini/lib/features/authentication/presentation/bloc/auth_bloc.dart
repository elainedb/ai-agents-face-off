import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/usecases/usecase.dart';
import '../../domain/usecases/get_current_user.dart';
import '../../domain/usecases/sign_in_with_google.dart';
import '../../domain/usecases/sign_out.dart';
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
      await event.when(
        checkAuthStatus: () async {
          final result = await _getCurrentUser(NoParams());
          result.fold(
            (failure) => emit(AuthState.error(failure.message)),
            (user) {
              if (user != null) {
                emit(AuthState.authenticated(user));
              } else {
                emit(const AuthState.unauthenticated());
              }
            },
          );
        },
        signInWithGoogle: () async {
          emit(const AuthState.loading());
          final result = await _signInWithGoogle(NoParams());
          result.fold(
            (failure) => emit(AuthState.error(failure.message)),
            (user) => emit(AuthState.authenticated(user)),
          );
        },
        signOut: () async {
          final result = await _signOut(NoParams());
          result.fold(
            (failure) => emit(AuthState.error(failure.message)),
            (_) => emit(const AuthState.unauthenticated()),
          );
        },
      );
    });
  }
}
