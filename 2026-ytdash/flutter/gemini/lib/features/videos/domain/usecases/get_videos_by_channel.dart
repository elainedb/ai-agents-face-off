import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/video.dart';
import '../repositories/videos_repository.dart';

class GetVideosByChannelParams {
  final String channelName;

  GetVideosByChannelParams(this.channelName);
}

@injectable
class GetVideosByChannel implements UseCase<List<Video>, GetVideosByChannelParams> {
  final VideosRepository repository;

  GetVideosByChannel(this.repository);

  @override
  Future<Either<Failure, List<Video>>> call(GetVideosByChannelParams params) async {
    return repository.getVideosByChannel(params.channelName);
  }
}
