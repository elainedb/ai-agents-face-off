import 'package:dartz/dartz.dart';

import '../../../../config/auth_config.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/app_user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_remote_data_source.dart';

class AuthRepositoryImpl implements AuthRepository {
  AuthRepositoryImpl({required this.remoteDataSource});

  final AuthRemoteDataSource remoteDataSource;

  @override
  Future<Either<Failure, AppUser?>> getCurrentUser() async {
    try {
      final user = await remoteDataSource.getCurrentUser();
      if (user == null) {
        return const Right(null);
      }
      if (!_isAuthorized(user.email)) {
        await remoteDataSource.signOut();
        return const Left(
          Failure.auth('Access denied. Your email is not authorized.'),
        );
      }

      return Right(user.toEntity());
    } on AuthException catch (error) {
      return Left(Failure.auth(error.message));
    } catch (error) {
      return Left(Failure.unexpected(error.toString()));
    }
  }

  @override
  Future<Either<Failure, AppUser>> signInWithGoogle() async {
    try {
      final user = await remoteDataSource.signInWithGoogle();
      if (!_isAuthorized(user.email)) {
        await remoteDataSource.signOut();
        return const Left(
          Failure.auth('Access denied. Your email is not authorized.'),
        );
      }

      return Right(user.toEntity());
    } on AuthException catch (error) {
      return Left(Failure.auth(error.message));
    } catch (error) {
      return Left(Failure.unexpected(error.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> signOut() async {
    try {
      await remoteDataSource.signOut();
      return const Right(null);
    } on AuthException catch (error) {
      return Left(Failure.auth(error.message));
    } catch (error) {
      return Left(Failure.unexpected(error.toString()));
    }
  }

  bool _isAuthorized(String email) {
    return AuthConfig.authorizedEmails
        .map((item) => item.toLowerCase())
        .contains(email.toLowerCase());
  }
}
