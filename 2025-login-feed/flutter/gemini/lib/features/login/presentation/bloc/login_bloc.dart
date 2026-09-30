import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gemini/core/usecases/usecase.dart';
import 'package:flutter_gemini/features/login/domain/usecases/is_email_authorized.dart';
import 'package:flutter_gemini/features/login/domain/usecases/login_with_google.dart'
    as use_case;
import 'package:flutter_gemini/features/login/presentation/bloc/login_event.dart';
import 'package:flutter_gemini/features/login/presentation/bloc/login_state.dart';
import 'package:google_sign_in/google_sign_in.dart'; // Added import
import 'package:injectable/injectable.dart';

@injectable
class LoginBloc extends Bloc<LoginEvent, LoginState> {
  final use_case.LoginWithGoogle _loginWithGoogle;
  final IsEmailAuthorized _isEmailAuthorized;
  final GoogleSignIn _googleSignIn; // Added field

  LoginBloc(this._loginWithGoogle, this._isEmailAuthorized, this._googleSignIn) : super(LoginInitial()) { // Modified constructor
    on<LoginWithGoogle>((event, emit) async {
      emit(LoginLoading());
      final result = await _loginWithGoogle(NoParams());
      await result.fold(
        (failure) async {
          await _googleSignIn.signOut(); // Added signOut
          emit(LoginError(failure.toString()));
        },
        (user) async {
          if (user != null) {
            final isAuthorizedResult = await _isEmailAuthorized(user.email);
            await isAuthorizedResult.fold( // Added await
              (failure) async { // Added async
                await _googleSignIn.signOut(); // Added signOut
                emit(LoginError(failure.toString()));
              },
              (isAuthorized) async { // Added async
                if (isAuthorized) {
                  emit(LoginSuccess(user));
                } else {
                  await _googleSignIn.signOut(); // Added signOut
                  emit(LoginError('Email not authorized.'));
                }
              },
            );
          } else {
            await _googleSignIn.signOut(); // Added signOut
            emit(LoginError('Login failed.'));
          }
        },
      );
    });
  }
}