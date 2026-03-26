import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '../../../../core/error/failures.dart';
import '../entities/video.dart';
import '../repositories/videos_repository.dart';

class GetVideosByChannel {
  const GetVideosByChannel(this.repository);

  final VideosRepository repository;

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
