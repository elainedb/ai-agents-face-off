import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:ytdash_flutter_claude/core/error/failures.dart';
import 'package:ytdash_flutter_claude/core/usecases/usecase.dart';
import 'package:ytdash_flutter_claude/features/videos/domain/entities/video.dart';
import 'package:ytdash_flutter_claude/features/videos/domain/repositories/videos_repository.dart';

class GetVideosByCountryParams {
  final String country;
  const GetVideosByCountryParams({required this.country});
}

@injectable
class GetVideosByCountry
    implements UseCase<List<Video>, GetVideosByCountryParams> {
  final VideosRepository repository;

  GetVideosByCountry(this.repository);

  @override
  Future<Either<Failure, List<Video>>> call(GetVideosByCountryParams params) {
    return repository.getVideosByCountry(params.country);
  }
}
