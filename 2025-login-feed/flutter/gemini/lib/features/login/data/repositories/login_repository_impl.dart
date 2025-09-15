
import 'package:dartz/dartz.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_gemini/core/config/app_config.dart';
import 'package:flutter_gemini/core/errors/failures.dart';
import 'package:flutter_gemini/features/login/data/datasources/login_remote_data_source.dart';
import 'package:flutter_gemini/features/login/domain/repositories/login_repository.dart';
import 'package:injectable/injectable.dart';

@LazySingleton(as: LoginRepository)
class LoginRepositoryImpl implements LoginRepository {
  final LoginRemoteDataSource remoteDataSource;

  LoginRepositoryImpl(this.remoteDataSource);

  @override
  Future<Either<Failure, Unit>> signInWithGoogle() async {
    try {
      final email = await remoteDataSource.signInWithGoogle();
      final authorizedEmails = await getAuthorizedEmails();
      debugPrint('Authorized emails: $authorizedEmails');
      if (authorizedEmails.any((authorizedEmail) => authorizedEmail.trim().toLowerCase() == email.toLowerCase())) {
        debugPrint('Access granted to $email');
        return const Right(unit);
      } else {
        await remoteDataSource.signOut();
        return const Left(Failure.server('Access denied. Your email is not authorized.'));
      }
    } catch (e) {
      return const Left(Failure.server('An unknown error occurred.'));
    }
  }

  @override
  Future<void> signOut() async {
    await remoteDataSource.signOut();
  }
}
