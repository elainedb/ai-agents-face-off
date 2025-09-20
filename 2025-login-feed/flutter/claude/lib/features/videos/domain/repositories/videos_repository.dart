import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../entities/video.dart';

abstract class VideosRepository {
  Future<Either<Failure, List<Video>>> getVideosFromChannels(
    List<String> channelIds, {
    bool forceRefresh = false,
  });

  Future<Either<Failure, List<Video>>> getVideosByChannel(String channelName);
  Future<Either<Failure, List<Video>>> getVideosByCountry(String country);
  Future<Either<Failure, void>> clearCache();
}