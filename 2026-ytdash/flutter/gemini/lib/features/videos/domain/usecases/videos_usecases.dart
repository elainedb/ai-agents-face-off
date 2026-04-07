import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/video.dart';
import '../repositories/videos_repository.dart';

class GetVideosParams {
  final List<String> channelIds;
  final bool forceRefresh;
  const GetVideosParams(this.channelIds, this.forceRefresh);
}

@injectable
class GetVideos implements UseCase<List<Video>, GetVideosParams> {
  final VideosRepository repository;
  GetVideos(this.repository);

  @override
  Future<Either<Failure, List<Video>>> call(GetVideosParams params) {
    return repository.getVideosFromChannels(params.channelIds, forceRefresh: params.forceRefresh);
  }
}

class GetVideosByChannelParams {
  final String channelName;
  const GetVideosByChannelParams(this.channelName);
}

@injectable
class GetVideosByChannel implements UseCase<List<Video>, GetVideosByChannelParams> {
  final VideosRepository repository;
  GetVideosByChannel(this.repository);

  @override
  Future<Either<Failure, List<Video>>> call(GetVideosByChannelParams params) {
    return repository.getVideosByChannel(params.channelName);
  }
}

class GetVideosByCountryParams {
  final String country;
  const GetVideosByCountryParams(this.country);
}

@injectable
class GetVideosByCountry implements UseCase<List<Video>, GetVideosByCountryParams> {
  final VideosRepository repository;
  GetVideosByCountry(this.repository);

  @override
  Future<Either<Failure, List<Video>>> call(GetVideosByCountryParams params) {
    return repository.getVideosByCountry(params.country);
  }
}
