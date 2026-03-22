import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/user.dart';
import '../repositories/auth_repository.dart';

@injectable
class SignInWithGoogle implements UseCase<User, NoParams> {
  SignInWithGoogle(this._repository);

  final AuthRepository _repository;

  @override
  Future<Either<Failure, User>> call(NoParams params) {
    return _repository.signInWithGoogle();
  }
}
