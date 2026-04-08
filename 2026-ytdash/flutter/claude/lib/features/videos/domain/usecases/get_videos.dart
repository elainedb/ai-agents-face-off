import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:ytdash_flutter_claude/core/error/failures.dart';
import 'package:ytdash_flutter_claude/core/usecases/usecase.dart';
import 'package:ytdash_flutter_claude/features/videos/domain/entities/video.dart';
import 'package:ytdash_flutter_claude/features/videos/domain/repositories/videos_repository.dart';

@injectable
class GetVideos implements UseCase<List<Video>, GetVideosParams> {
  final VideosRepository repository;

  GetVideos(this.repository);

  @override
  Future<Either<Failure, List<Video>>> call(GetVideosParams params) {
    return repository.getVideosFromChannels(
      params.channelIds,
      forceRefresh: params.forceRefresh,
    );
  }
}

class GetVideosParams {
  final List<String> channelIds;
  final bool forceRefresh;

  const GetVideosParams({
    required this.channelIds,
    this.forceRefresh = false,
  });
}
