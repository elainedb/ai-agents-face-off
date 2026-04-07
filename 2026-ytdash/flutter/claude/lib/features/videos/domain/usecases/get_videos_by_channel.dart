import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:ytdash_flutter_claude/core/error/failures.dart';
import 'package:ytdash_flutter_claude/core/usecases/usecase.dart';
import 'package:ytdash_flutter_claude/features/videos/domain/entities/video.dart';
import 'package:ytdash_flutter_claude/features/videos/domain/repositories/videos_repository.dart';

class GetVideosByChannelParams {
  final String channelName;
  const GetVideosByChannelParams({required this.channelName});
}

@injectable
class GetVideosByChannel
    implements UseCase<List<Video>, GetVideosByChannelParams> {
  final VideosRepository repository;

  GetVideosByChannel(this.repository);

  @override
  Future<Either<Failure, List<Video>>> call(GetVideosByChannelParams params) {
    return repository.getVideosByChannel(params.channelName);
  }
}
