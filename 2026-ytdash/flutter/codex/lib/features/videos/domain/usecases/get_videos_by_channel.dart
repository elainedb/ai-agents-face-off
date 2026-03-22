import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/video.dart';
import '../repositories/videos_repository.dart';

class GetVideosByChannelParams extends Equatable {
  const GetVideosByChannelParams(this.channelName);

  final String channelName;

  @override
  List<Object?> get props => <Object?>[channelName];
}

@injectable
class GetVideosByChannel
    implements UseCase<List<Video>, GetVideosByChannelParams> {
  GetVideosByChannel(this._repository);

  final VideosRepository _repository;

  @override
  Future<Either<Failure, List<Video>>> call(GetVideosByChannelParams params) {
    return _repository.getVideosByChannel(params.channelName);
  }
}
