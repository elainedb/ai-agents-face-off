
import 'package:dartz/dartz.dart';
import 'package:flutter_gemini/core/errors/failures.dart';

abstract class LoginRepository {
  Future<Either<Failure, Unit>> signInWithGoogle();
  Future<void> signOut();
}
