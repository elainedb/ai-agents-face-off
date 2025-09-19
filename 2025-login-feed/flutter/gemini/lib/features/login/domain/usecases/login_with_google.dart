import 'package:dartz/dartz.dart';
import 'package:flutter_gemini/core/errors/failures.dart';
import 'package:flutter_gemini/core/usecases/usecase.dart';
import 'package:flutter_gemini/features/login/domain/repositories/login_repository.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:injectable/injectable.dart';

@injectable
class LoginWithGoogle implements UseCase<GoogleSignInAccount?, NoParams> {
  final LoginRepository repository;

  LoginWithGoogle(this.repository);

  @override
  Future<Either<Failure, GoogleSignInAccount?>> call(NoParams params) async {
    return await repository.loginWithGoogle();
  }
}
