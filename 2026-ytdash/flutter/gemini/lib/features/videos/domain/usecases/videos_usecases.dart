import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/video.dart';
import '../repositories/videos_repository.dart';

class GetVideosParams {
  final List<String> channelIds;
  final bool forceRefresh;

  GetVideosParams({required this.channelIds, this.forceRefresh = false});
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

class GetVideosByChannelParams {
  final String channelName;

  GetVideosByChannelParams(this.channelName);
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

class GetVideosByCountryParams {
  final String country;

  GetVideosByCountryParams(this.country);
}

@injectable
class GetVideosByCountry implements UseCase<List<Video>, GetVideosByCountryParams> {
  final VideosRepository repository;

  GetVideosByCountry(this.repository);

  @override
  Future<Either<Failure, List<Video>>> call(GetVideosByCountryParams params) async {
    return await repository.getVideosByCountry(params.country);
  }
}
