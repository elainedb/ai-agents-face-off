import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/videos_repository.dart';

@injectable
class ClearCache implements UseCase<void, NoParams> {
  final VideosRepository repository;

  ClearCache(this.repository);

  @override
  Future<Either<Failure, void>> call(NoParams params) async {
    return await repository.clearCache();
  }
}
