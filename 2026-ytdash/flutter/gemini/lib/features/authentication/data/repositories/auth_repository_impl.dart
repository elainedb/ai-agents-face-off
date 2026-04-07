import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:ytdash_flutter_gemini/config/auth_config.dart';
import 'package:ytdash_flutter_gemini/core/error/exceptions.dart';
import 'package:ytdash_flutter_gemini/core/error/failures.dart';
import 'package:ytdash_flutter_gemini/features/authentication/data/datasources/auth_remote_data_source.dart';
import 'package:ytdash_flutter_gemini/features/authentication/domain/entities/user.dart';
import 'package:ytdash_flutter_gemini/features/authentication/domain/repositories/auth_repository.dart';

@LazySingleton(as: AuthRepository)
class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;

  AuthRepositoryImpl(this.remoteDataSource);

  @override
  Future<Either<Failure, User>> signInWithGoogle() async {
    try {
      final userModel = await remoteDataSource.signInWithGoogle();
      
      if (!AuthConfig.authorizedEmails.contains(userModel.email)) {
        await remoteDataSource.signOut();
        return const Left(Failure.auth(message: 'Access denied. Your email is not authorized.'));
      }
      
      return Right(userModel.toEntity());
    } on AuthException catch (e) {
      return Left(Failure.auth(message: e.message));
    } catch (e) {
      return Left(Failure.unexpected(message: 'An unexpected error occurred during sign in: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, void>> signOut() async {
    try {
      await remoteDataSource.signOut();
      return const Right(null);
    } on AuthException catch (e) {
      return Left(Failure.auth(message: e.message));
    } catch (e) {
      return Left(Failure.unexpected(message: 'An unexpected error occurred during sign out: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, User?>> getCurrentUser() async {
    try {
      final userModel = await remoteDataSource.getCurrentUser();
      
      if (userModel != null) {
        if (!AuthConfig.authorizedEmails.contains(userModel.email)) {
          await remoteDataSource.signOut();
          return const Right(null);
        }
        return Right(userModel.toEntity());
      }
      
      return const Right(null);
    } on AuthException catch (e) {
      return Left(Failure.auth(message: e.message));
    } catch (e) {
      return Left(Failure.unexpected(message: 'An unexpected error occurred getting current user: ${e.toString()}'));
    }
  }
}
