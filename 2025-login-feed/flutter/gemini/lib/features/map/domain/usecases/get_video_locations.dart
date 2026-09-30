
import 'package:dartz/dartz.dart';
import 'package:flutter_gemini/core/errors/failures.dart';
import 'package:flutter_gemini/core/usecases/usecase.dart';
import 'package:flutter_gemini/features/map/domain/entities/video_location.dart';
import 'package:flutter_gemini/features/map/domain/repositories/map_repository.dart';
import 'package:injectable/injectable.dart';

@injectable
class GetVideoLocations implements UseCase<List<VideoLocation>, NoParams> {
  final MapRepository repository;

  GetVideoLocations(this.repository);

  @override
  Future<Either<Failure, List<VideoLocation>>> call(NoParams params) async {
    return await repository.getVideoLocations();
  }
}
