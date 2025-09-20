
import 'package:dartz/dartz.dart';
import 'package:flutter_gemini/core/errors/failures.dart';
import 'package:flutter_gemini/features/map/domain/entities/video_location.dart';
import 'package:flutter_gemini/features/map/domain/repositories/map_repository.dart';
import 'package:flutter_gemini/features/video/domain/repositories/video_repository.dart';
import 'package:injectable/injectable.dart';
import 'package:latlong2/latlong.dart';

@LazySingleton(as: MapRepository)
class MapRepositoryImpl implements MapRepository {
  final VideoRepository videoRepository;

  MapRepositoryImpl(this.videoRepository);

  @override
  Future<Either<Failure, List<VideoLocation>>> getVideoLocations() async {
    final videosResult = await videoRepository.getVideos();
    return videosResult.fold(
      (failure) => Left(failure),
      (videos) {
        final locations = videos
            .where((video) => video.latitude != null && video.longitude != null)
            .map((video) => VideoLocation(
                  id: video.id,
                  title: video.title,
                  thumbnailUrl: video.thumbnailUrl,
                  channelTitle: video.channelTitle,
                  publicationDate: video.publishedAt,
                  tags: video.tags,
                  city: video.locationDescription,
                  country: video.country,
                  coordinates: LatLng(video.latitude!, video.longitude!),
                  recordingDate: video.recordingDate,
                  videoUrl: 'https://www.youtube.com/watch?v=${video.id}',
                ))
            .toList();
        return Right(locations);
      },
    );
  }
}
