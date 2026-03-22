import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/video.dart';
import '../repositories/videos_repository.dart';

class GetVideosParams extends Equatable {
  const GetVideosParams({required this.channelIds, this.forceRefresh = false});

  final List<String> channelIds;
  final bool forceRefresh;

  @override
  List<Object?> get props => <Object?>[channelIds, forceRefresh];
}

@injectable
class GetVideos implements UseCase<List<Video>, GetVideosParams> {
  GetVideos(this._repository);

  final VideosRepository _repository;

  @override
  Future<Either<Failure, List<Video>>> call(GetVideosParams params) {
    return _repository.getVideosFromChannels(
      params.channelIds,
      forceRefresh: params.forceRefresh,
    );
  }
}
