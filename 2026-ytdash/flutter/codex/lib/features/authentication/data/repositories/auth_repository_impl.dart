import 'package:dartz/dartz.dart';

import '../../../../config/auth_config.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_remote_data_source.dart';

class AuthRepositoryImpl implements AuthRepository {
  const AuthRepositoryImpl({required this.remoteDataSource});

  final AuthRemoteDataSource remoteDataSource;

  @override
  Future<Either<Failure, User?>> getCurrentUser() async {
    try {
      final user = await remoteDataSource.getCurrentUser();
      if (user == null) {
        return const Right(null);
      }
      if (!_isAuthorized(user.email)) {
        await remoteDataSource.signOut();
        return const Left(
          AuthFailure('Access denied. Your email is not authorized.'),
        );
      }
      return Right(user.toEntity());
    } on AuthException catch (error) {
      return Left(AuthFailure(error.message));
    } catch (error) {
      return Left(UnexpectedFailure(error.toString()));
    }
  }

  @override
  Future<Either<Failure, User>> signInWithGoogle() async {
    try {
      final user = await remoteDataSource.signInWithGoogle();
      if (!_isAuthorized(user.email)) {
        await remoteDataSource.signOut();
        return const Left(
          AuthFailure('Access denied. Your email is not authorized.'),
        );
      }
      return Right(user.toEntity());
    } on AuthException catch (error) {
      return Left(AuthFailure(error.message));
    } catch (error) {
      return Left(UnexpectedFailure(error.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> signOut() async {
    try {
      await remoteDataSource.signOut();
      return const Right(null);
    } on AuthException catch (error) {
      return Left(AuthFailure(error.message));
    } catch (error) {
      return Left(UnexpectedFailure(error.toString()));
    }
  }

  bool _isAuthorized(String email) {
    return AuthConfig.authorizedEmails
        .map((item) => item.trim().toLowerCase())
        .contains(email.trim().toLowerCase());
  }
}
