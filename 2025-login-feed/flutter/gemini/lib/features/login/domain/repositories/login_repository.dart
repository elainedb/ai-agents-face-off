import 'package:dartz/dartz.dart';
import 'package:flutter_gemini/core/errors/failures.dart';
import 'package:google_sign_in/google_sign_in.dart';

abstract class LoginRepository {
  Future<Either<Failure, GoogleSignInAccount?>> loginWithGoogle();
}