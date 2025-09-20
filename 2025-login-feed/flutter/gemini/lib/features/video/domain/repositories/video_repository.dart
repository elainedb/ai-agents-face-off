import 'package:dartz/dartz.dart';
import 'package:flutter_gemini/core/errors/failures.dart';
import 'package:flutter_gemini/features/video/domain/entities/video.dart';

abstract class VideoRepository {
  Future<Either<Failure, List<Video>>> getVideos({bool forceRefresh = false});
}