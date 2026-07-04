import '../../../../core/error/failures.dart';
import '../../../../core/error/result.dart';
import '../../domain/models/video.dart';
import '../../domain/repositories/video_repository.dart';
import '../datasources/video_local_data_source.dart';
import '../datasources/youtube_remote_data_source.dart';

class VideoRepositoryImpl implements VideoRepository {
  final YoutubeRemoteDataSource remoteDataSource;
  final VideoLocalDataSource localDataSource;

  VideoRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
  });

  @override
  Future<Result<List<Video>>> getVideos() async {
    try {
      final remoteVideos = await remoteDataSource.fetchAllVideos();
      await localDataSource.cacheVideos(remoteVideos);
      return Success(remoteVideos);
    } catch (e) {
      // Fallback to cache on any error (network, parse, etc)
      try {
        final cached = await localDataSource.getCachedVideos();
        if (cached.isNotEmpty) {
          return Success(cached);
        } else {
          return Error(
            ServerFailure('Failed to fetch and no cache available.'),
          );
        }
      } catch (cacheError) {
        return Error(ServerFailure('Failed to fetch and cache read failed.'));
      }
    }
  }
}
