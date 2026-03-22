import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/videos_repository.dart';

class ClearCache extends UseCase<void, NoParams> {
  ClearCache(this.repository);

  final VideosRepository repository;

  @override
  Future<Either<Failure, void>> call(NoParams params) {
    return repository.clearCache();
  }
}
