
import 'package:dartz/dartz.dart';
import 'package:flutter_gemini/core/errors/failures.dart';
import 'package:flutter_gemini/features/map/domain/entities/video_location.dart';

abstract class MapRepository {
  Future<Either<Failure, List<VideoLocation>>> getVideoLocations();
}
