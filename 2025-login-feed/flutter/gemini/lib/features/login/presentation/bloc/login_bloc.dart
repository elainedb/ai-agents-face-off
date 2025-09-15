
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:injectable/injectable.dart';
import 'package:flutter_gemini/features/login/domain/usecases/sign_in_with_google.dart';
import 'package:flutter_gemini/features/login/domain/usecases/sign_out.dart';

part 'login_event.dart';
part 'login_state.dart';
part 'login_bloc.freezed.dart';

@injectable
class LoginBloc extends Bloc<LoginEvent, LoginState> {
  final SignInWithGoogle _signInWithGoogle;
  final SignOut _signOut;

  LoginBloc(this._signInWithGoogle, this._signOut) : super(const _Initial()) {
    on<LoginEvent>((event, emit) async {
      await event.when(
        signInWithGoogle: () async {
          emit(const LoginState.loading());
          final result = await _signInWithGoogle();
          result.fold(
            (failure) => emit(LoginState.error(failure.message)),
            (_) => emit(const LoginState.success()),
          );
        },
        signOut: () async {
          await _signOut();
          emit(const LoginState.initial());
        },
      );
    });
  }
}
