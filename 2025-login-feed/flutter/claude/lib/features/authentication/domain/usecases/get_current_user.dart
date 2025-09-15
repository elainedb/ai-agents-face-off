import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/user.dart';
import '../repositories/auth_repository.dart';

@injectable
class GetCurrentUser extends UseCase<User?, NoParams> {
  final AuthRepository _repository;

  GetCurrentUser(this._repository);

  @override
  Future<Either<Failure, User?>> call(NoParams params) async {
    return await _repository.getCurrentUser();
  }
}