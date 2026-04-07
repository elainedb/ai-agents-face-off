import 'package:dartz/dartz.dart';

import '../../../../config/auth_config.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_remote_data_source.dart';

class AuthRepositoryImpl implements AuthRepository {
  AuthRepositoryImpl({required this.remoteDataSource});

  final AuthRemoteDataSource remoteDataSource;

  @override
  Future<Either<Failure, User?>> getCurrentUser() async {
    try {
      final user = await remoteDataSource.getCurrentUser();
      if (user == null) {
        return const Right<Failure, User?>(null);
      }

      if (!_isAuthorized(user.email)) {
        await remoteDataSource.signOut();
        return const Left<Failure, User?>(
          Failure.auth('Access denied. Your email is not authorized.'),
        );
      }

      return Right<Failure, User?>(user.toEntity());
    } on AuthException catch (error) {
      return Left<Failure, User?>(Failure.auth(error.message));
    } catch (error) {
      return Left<Failure, User?>(
        Failure.unexpected('Unexpected auth error: $error'),
      );
    }
  }

  @override
  Future<Either<Failure, User>> signInWithGoogle() async {
    try {
      final user = await remoteDataSource.signInWithGoogle();
      if (!_isAuthorized(user.email)) {
        await remoteDataSource.signOut();
        return const Left<Failure, User>(
          Failure.auth('Access denied. Your email is not authorized.'),
        );
      }

      return Right<Failure, User>(user.toEntity());
    } on AuthException catch (error) {
      return Left<Failure, User>(Failure.auth(error.message));
    } catch (error) {
      return Left<Failure, User>(
        Failure.unexpected('Unexpected auth error: $error'),
      );
    }
  }

  @override
  Future<Either<Failure, void>> signOut() async {
    try {
      await remoteDataSource.signOut();
      return const Right<Failure, void>(null);
    } on AuthException catch (error) {
      return Left<Failure, void>(Failure.auth(error.message));
    } catch (error) {
      return Left<Failure, void>(
        Failure.unexpected('Unexpected auth error: $error'),
      );
    }
  }

  bool _isAuthorized(String email) {
    return AuthConfig.authorizedEmails
        .map((String value) => value.toLowerCase())
        .contains(email.toLowerCase());
  }
}
