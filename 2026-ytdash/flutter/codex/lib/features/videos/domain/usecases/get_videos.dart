import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '../../../../core/error/failures.dart';
import '../entities/video.dart';
import '../repositories/videos_repository.dart';

class GetVideos {
  const GetVideos(this.repository);

  final VideosRepository repository;

  Future<Either<Failure, List<Video>>> call(GetVideosParams params) {
    return repository.getVideosFromChannels(
      params.channelIds,
      forceRefresh: params.forceRefresh,
    );
  }
}

class GetVideosParams extends Equatable {
  const GetVideosParams({required this.channelIds, this.forceRefresh = false});

  final List<String> channelIds;
  final bool forceRefresh;

  @override
  List<Object?> get props => [channelIds, forceRefresh];
}
