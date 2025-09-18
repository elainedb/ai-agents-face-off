import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../entities/video.dart';

abstract class VideosRepository {
  Future<Either<Failure, List<Video>>> getVideosFromChannels(
    List<String> channelIds,
  );
}