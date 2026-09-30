import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import '../../../../config/auth_config.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_remote_datasource.dart';

@LazySingleton(as: AuthRepository)
class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource _remoteDataSource;

  static const List<String> authorizedEmails = AuthConfig.authorizedEmails;

  AuthRepositoryImpl(this._remoteDataSource);

  @override
  Future<Either<Failure, User>> signInWithGoogle() async {
    try {
      final userModel = await _remoteDataSource.signInWithGoogle();
      final user = userModel.toEntity();

      if (!authorizedEmails.contains(user.email)) {
        await _remoteDataSource.signOut();
        return const Left(AuthFailure(
            'Access denied. Your email is not authorized.'));
      }

      return Right(user);
    } on AuthException catch (e) {
      return Left(AuthFailure(e.message));
    } catch (e) {
      return Left(UnexpectedFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> signOut() async {
    try {
      await _remoteDataSource.signOut();
      return const Right(null);
    } on AuthException catch (e) {
      return Left(AuthFailure(e.message));
    } catch (e) {
      return Left(UnexpectedFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, User?>> getCurrentUser() async {
    try {
      final userModel = await _remoteDataSource.getCurrentUser();
      if (userModel == null) return const Right(null);

      final user = userModel.toEntity();

      if (!authorizedEmails.contains(user.email)) {
        await _remoteDataSource.signOut();
        return const Left(AuthFailure(
            'Access denied. Your email is not authorized.'));
      }

      return Right(user);
    } on AuthException catch (e) {
      return Left(AuthFailure(e.message));
    } catch (e) {
      return Left(UnexpectedFailure(e.toString()));
    }
  }

  @override
  Stream<User?> watchAuthState() {
    return _remoteDataSource.watchAuthState().map((userModel) {
      if (userModel == null) return null;

      final user = userModel.toEntity();

      if (!authorizedEmails.contains(user.email)) {
        return null;
      }

      return user;
    });
  }
}