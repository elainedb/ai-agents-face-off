import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import '../../../../config/auth_config.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_remote_data_source.dart';

@LazySingleton(as: AuthRepository)
class AuthRepositoryImpl implements AuthRepository {
  const AuthRepositoryImpl(this._remoteDataSource);

  final AuthRemoteDataSource _remoteDataSource;

  @override
  Future<Either<Failure, User?>> getCurrentUser() async {
    try {
      final userModel = await _remoteDataSource.getCurrentUser();
      if (userModel == null) {
        return const Right(null);
      }
      if (!_isAuthorized(userModel.email)) {
        await _remoteDataSource.signOut();
        return const Left(
          Failure.auth('Access denied. Your email is not authorized.'),
        );
      }
      return Right(userModel.toEntity());
    } on AuthException catch (error) {
      return Left(Failure.auth(error.message));
    } catch (error) {
      return Left(Failure.unexpected(error.toString()));
    }
  }

  @override
  Future<Either<Failure, User>> signInWithGoogle() async {
    try {
      final userModel = await _remoteDataSource.signInWithGoogle();
      if (!_isAuthorized(userModel.email)) {
        await _remoteDataSource.signOut();
        return const Left(
          Failure.auth('Access denied. Your email is not authorized.'),
        );
      }
      return Right(userModel.toEntity());
    } on AuthException catch (error) {
      return Left(Failure.auth(error.message));
    } catch (error) {
      return Left(Failure.unexpected(error.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> signOut() async {
    try {
      await _remoteDataSource.signOut();
      return const Right(null);
    } on AuthException catch (error) {
      return Left(Failure.auth(error.message));
    } catch (error) {
      return Left(Failure.unexpected(error.toString()));
    }
  }

  bool _isAuthorized(String email) {
    return AuthConfig.authorizedEmails.any(
      (allowedEmail) => allowedEmail.toLowerCase() == email.toLowerCase(),
    );
  }
}
