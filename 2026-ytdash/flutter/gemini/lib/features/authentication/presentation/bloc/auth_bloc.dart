import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/usecases/usecase.dart';
import '../../domain/usecases/get_current_user.dart';
import '../../domain/usecases/sign_in_with_google.dart';
import '../../domain/usecases/sign_out.dart';
import 'auth_event.dart';
import 'auth_state.dart';
export 'auth_event.dart';
export 'auth_state.dart';

@injectable
class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final GetCurrentUser getCurrentUser;
  final SignInWithGoogle signInWithGoogle;
  final SignOut signOut;

  AuthBloc({
    required this.getCurrentUser,
    required this.signInWithGoogle,
    required this.signOut,
  }) : super(const AuthState.initial()) {
    on<AuthEvent>((event, emit) async {
      await event.map(
        checkAuthStatus: (_) async {
          final result = await getCurrentUser(const NoParams());
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
        },
        signInWithGoogle: (_) async {
          emit(const AuthState.loading());
          final result = await signInWithGoogle(const NoParams());
          result.fold(
            (failure) => emit(AuthState.error(failure.message)),
            (user) => emit(AuthState.authenticated(user)),
          );
        },
        signOut: (_) async {
          await signOut(const NoParams());
          emit(const AuthState.unauthenticated());
        },
      );
    });
  }
}
