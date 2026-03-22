import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:injectable/injectable.dart';
import 'package:ytdash_flutter_gemini/core/error/failures.dart';
import 'package:ytdash_flutter_gemini/core/usecases/usecase.dart';
import 'package:ytdash_flutter_gemini/features/videos/domain/entities/video.dart';
import 'package:ytdash_flutter_gemini/features/videos/domain/repositories/videos_repository.dart';

class GetVideosParams extends Equatable {
  final List<String> channelIds;
  final bool forceRefresh;

  const GetVideosParams({required this.channelIds, this.forceRefresh = false});

  @override
  List<Object?> get props => [channelIds, forceRefresh];
}

@injectable
class GetVideos implements UseCase<List<Video>, GetVideosParams> {
  final VideosRepository repository;

  GetVideos(this.repository);

  @override
  Future<Either<Failure, List<Video>>> call(GetVideosParams params) async {
    return await repository.getVideosFromChannels(
      params.channelIds,
      forceRefresh: params.forceRefresh,
    );
  }
}
