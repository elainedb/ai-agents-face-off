import 'package:dartz/dartz.dart';
import 'package:flutter_gemini/core/errors/failures.dart';
import 'package:flutter_gemini/features/login/data/datasources/auth_local_data_source.dart';
import 'package:flutter_gemini/features/login/domain/repositories/auth_repository.dart';
import 'package:injectable/injectable.dart';

@LazySingleton(as: AuthRepository)
class AuthRepositoryImpl implements AuthRepository {
  final AuthLocalDataSource localDataSource;

  AuthRepositoryImpl({required this.localDataSource});

  @override
  Future<Either<Failure, bool>> isEmailAuthorized(String email) async {
    try {
      final authorizedEmails = await localDataSource.getAuthorizedEmails();
      final isAuthorized = authorizedEmails.contains(email);
      print('Checking email: $email, Is authorized: $isAuthorized');
      return Right(isAuthorized);
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }
}
