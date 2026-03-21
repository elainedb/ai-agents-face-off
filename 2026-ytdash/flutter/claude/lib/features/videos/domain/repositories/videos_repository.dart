import 'package:dartz/dartz.dart';
import 'package:ytdash_flutter_claude/core/error/failures.dart';
import 'package:ytdash_flutter_claude/features/videos/domain/entities/video.dart';

abstract class VideosRepository {
  Future<Either<Failure, List<Video>>> getVideosFromChannels(
    List<String> channelIds, {
    bool forceRefresh = false,
  });
  Future<Either<Failure, List<Video>>> getVideosByChannel(String channelName);
  Future<Either<Failure, List<Video>>> getVideosByCountry(String country);
  Future<Either<Failure, void>> clearCache();
}
