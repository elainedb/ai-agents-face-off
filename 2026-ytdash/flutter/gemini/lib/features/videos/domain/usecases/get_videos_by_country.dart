import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:injectable/injectable.dart';
import 'package:ytdash_flutter_gemini/core/error/failures.dart';
import 'package:ytdash_flutter_gemini/core/usecases/usecase.dart';
import 'package:ytdash_flutter_gemini/features/videos/domain/entities/video.dart';
import 'package:ytdash_flutter_gemini/features/videos/domain/repositories/videos_repository.dart';

class GetVideosByCountryParams extends Equatable {
  final String country;

  const GetVideosByCountryParams({required this.country});

  @override
  List<Object?> get props => [country];
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
