import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:ytdash_flutter_gemini/core/error/failures.dart';
import 'package:ytdash_flutter_gemini/core/usecases/usecase.dart';
import 'package:ytdash_flutter_gemini/features/authentication/domain/entities/user.dart';
import 'package:ytdash_flutter_gemini/features/authentication/domain/repositories/auth_repository.dart';

@injectable
class GetCurrentUser implements UseCase<User?, NoParams> {
  final AuthRepository repository;

  GetCurrentUser(this.repository);

  @override
  Future<Either<Failure, User?>> call(NoParams params) {
    return repository.getCurrentUser();
  }
}
