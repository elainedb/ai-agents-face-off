import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/video.dart';
import '../repositories/videos_repository.dart';

class GetVideosByCountryParams {
  final String country;
  const GetVideosByCountryParams(this.country);
}

@injectable
class GetVideosByCountry implements UseCase<List<Video>, GetVideosByCountryParams> {
  final VideosRepository repository;

  GetVideosByCountry(this.repository);

  @override
  Future<Either<Failure, List<Video>>> call(GetVideosByCountryParams params) async {
    return await repository.getVideosByCountry(params.country);
  }
}
