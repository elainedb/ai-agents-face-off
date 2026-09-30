import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:equatable/equatable.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/video.dart';
import '../repositories/videos_repository.dart';

@injectable
class GetVideosByChannel implements UseCase<List<Video>, GetVideosByChannelParams> {
  final VideosRepository repository;

  GetVideosByChannel(this.repository);

  @override
  Future<Either<Failure, List<Video>>> call(GetVideosByChannelParams params) async {
    return await repository.getVideosByChannel(params.channelName);
  }
}

class GetVideosByChannelParams extends Equatable {
  final String channelName;

  const GetVideosByChannelParams({required this.channelName});

  @override
  List<Object?> get props => [channelName];
}