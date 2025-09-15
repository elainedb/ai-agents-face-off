
import 'package:dartz/dartz.dart';
import 'package:flutter_gemini/core/errors/failures.dart';
import 'package:flutter_gemini/features/login/domain/repositories/login_repository.dart';
import 'package:injectable/injectable.dart';

@injectable
class SignInWithGoogle {
  final LoginRepository repository;

  SignInWithGoogle(this.repository);

  Future<Either<Failure, Unit>> call() {
    return repository.signInWithGoogle();
  }
}
