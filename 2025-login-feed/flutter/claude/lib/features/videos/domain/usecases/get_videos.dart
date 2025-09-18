import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/video.dart';
import '../repositories/videos_repository.dart';

@injectable
class GetVideos implements UseCase<List<Video>, GetVideosParams> {
  final VideosRepository repository;

  GetVideos(this.repository);

  @override
  Future<Either<Failure, List<Video>>> call(GetVideosParams params) async {
    return await repository.getVideosFromChannels(params.channelIds);
  }
}

class GetVideosParams {
  final List<String> channelIds;

  GetVideosParams({required this.channelIds});
}