import 'package:dartz/dartz.dart';
import 'package:flutter_gemini/core/errors/failures.dart';

abstract class AuthRepository {
  Future<Either<Failure, bool>> isEmailAuthorized(String email);
}
