import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/video.dart';
import '../repositories/videos_repository.dart';

class GetVideosByChannel
    extends UseCase<List<Video>, GetVideosByChannelParams> {
  GetVideosByChannel(this.repository);

  final VideosRepository repository;

  @override
  Future<Either<Failure, List<Video>>> call(GetVideosByChannelParams params) {
    return repository.getVideosByChannel(params.channelName);
  }
}

class GetVideosByChannelParams extends Equatable {
  const GetVideosByChannelParams(this.channelName);

  final String channelName;

  @override
  List<Object?> get props => [channelName];
}
