import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:equatable/equatable.dart';

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
    return await repository.getVideosFromChannels(
      params.channelIds,
      forceRefresh: params.forceRefresh,
    );
  }
}

class GetVideosParams extends Equatable {
  final List<String> channelIds;
  final bool forceRefresh;

  const GetVideosParams({
    required this.channelIds,
    this.forceRefresh = false,
  });

  @override
  List<Object?> get props => [channelIds, forceRefresh];
}