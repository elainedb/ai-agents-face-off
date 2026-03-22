import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:injectable/injectable.dart';
import 'package:ytdash_flutter_gemini/core/error/failures.dart';
import 'package:ytdash_flutter_gemini/core/usecases/usecase.dart';
import 'package:ytdash_flutter_gemini/features/videos/domain/entities/video.dart';
import 'package:ytdash_flutter_gemini/features/videos/domain/repositories/videos_repository.dart';

class GetVideosByChannelParams extends Equatable {
  final String channelName;

  const GetVideosByChannelParams({required this.channelName});

  @override
  List<Object?> get props => [channelName];
}

@injectable
class GetVideosByChannel implements UseCase<List<Video>, GetVideosByChannelParams> {
  final VideosRepository repository;

  GetVideosByChannel(this.repository);

  @override
  Future<Either<Failure, List<Video>>> call(GetVideosByChannelParams params) async {
    return await repository.getVideosByChannel(params.channelName);
  }
}
