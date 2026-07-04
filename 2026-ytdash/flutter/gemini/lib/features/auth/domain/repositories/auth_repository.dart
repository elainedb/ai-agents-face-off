import '../../../../core/error/result.dart';

abstract class AuthRepository {
  Future<Result<String>> signInWithGoogle();
  Future<Result<void>> signOut();
  Future<Result<String?>> getSignedInUser();
}
