import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:injectable/injectable.dart';
import 'package:ytdash_flutter_claude/core/usecases/usecase.dart';
import 'package:ytdash_flutter_claude/features/authentication/domain/entities/user.dart';
import 'package:ytdash_flutter_claude/features/authentication/domain/usecases/get_current_user.dart';
import 'package:ytdash_flutter_claude/features/authentication/domain/usecases/sign_in_with_google.dart';
import 'package:ytdash_flutter_claude/features/authentication/domain/usecases/sign_out.dart';

part 'auth_bloc.freezed.dart';

@freezed
sealed class AuthEvent with _$AuthEvent {
  const factory AuthEvent.signInWithGoogle() = _SignInWithGoogle;
  const factory AuthEvent.signOut() = _SignOut;
  const factory AuthEvent.checkAuthStatus() = _CheckAuthStatus;
}

@freezed
sealed class AuthState with _$AuthState {
  const factory AuthState.initial() = _Initial;
  const factory AuthState.loading() = _Loading;
  const factory AuthState.authenticated(User user) = _Authenticated;
  const factory AuthState.unauthenticated() = _Unauthenticated;
  const factory AuthState.error(String message) = _Error;
}

@injectable
class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final SignInWithGoogle _signInWithGoogle;
  final SignOut _signOut;
  final GetCurrentUser _getCurrentUser;

  AuthBloc(this._signInWithGoogle, this._signOut, this._getCurrentUser)
      : super(const AuthState.initial()) {
    on<AuthEvent>((event, emit) async {
      await event.map(
        checkAuthStatus: (_) async {
          final result = await _getCurrentUser(const NoParams());
          result.fold(
            (failure) => emit(const AuthState.unauthenticated()),
            (user) => user != null
                ? emit(AuthState.authenticated(user))
                : emit(const AuthState.unauthenticated()),
          );
        },
        signInWithGoogle: (_) async {
          emit(const AuthState.loading());
          final result = await _signInWithGoogle(const NoParams());
          result.fold(
            (failure) => emit(AuthState.error(failure.message)),
            (user) => emit(AuthState.authenticated(user)),
          );
        },
        signOut: (_) async {
          await _signOut(const NoParams());
          emit(const AuthState.unauthenticated());
        },
      );
    });
  }
}
