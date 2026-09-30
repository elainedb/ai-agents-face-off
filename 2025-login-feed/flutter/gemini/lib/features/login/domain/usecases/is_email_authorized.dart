import 'package:dartz/dartz.dart';
import 'package:flutter_gemini/core/errors/failures.dart';
import 'package:flutter_gemini/core/usecases/usecase.dart';
import 'package:flutter_gemini/features/login/domain/repositories/auth_repository.dart';
import 'package:injectable/injectable.dart';

@injectable
class IsEmailAuthorized implements UseCase<bool, String> {
  final AuthRepository repository;

  IsEmailAuthorized(this.repository);

  @override
  Future<Either<Failure, bool>> call(String email) async {
    return await repository.isEmailAuthorized(email);
  }
}
