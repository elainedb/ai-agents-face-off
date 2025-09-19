import 'package:dartz/dartz.dart';
import 'package:flutter_gemini/core/errors/failures.dart';
import 'package:flutter_gemini/core/usecases/usecase.dart';
import 'package:flutter_gemini/features/video/domain/entities/video.dart';
import 'package:flutter_gemini/features/video/domain/repositories/video_repository.dart';
import 'package:injectable/injectable.dart';

@injectable
class GetVideos implements UseCase<List<Video>, NoParams> {
  final VideoRepository repository;

  GetVideos(this.repository);

  @override
  Future<Either<Failure, List<Video>>> call(NoParams params) async {
    return await repository.getVideos();
  }
}
