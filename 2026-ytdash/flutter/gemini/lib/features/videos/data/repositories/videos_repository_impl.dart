import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:ytdash_flutter_gemini/core/error/exceptions.dart';
import 'package:ytdash_flutter_gemini/core/error/failures.dart';
import 'package:ytdash_flutter_gemini/features/videos/data/datasources/videos_local_data_source.dart';
import 'package:ytdash_flutter_gemini/features/videos/data/datasources/videos_remote_data_source.dart';
import 'package:ytdash_flutter_gemini/features/videos/domain/entities/video.dart';
import 'package:ytdash_flutter_gemini/features/videos/domain/repositories/videos_repository.dart';

@LazySingleton(as: VideosRepository)
class VideosRepositoryImpl implements VideosRepository {
  final VideosRemoteDataSource remoteDataSource;
  final VideosLocalDataSource localDataSource;

  VideosRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
  });

  @override
  Future<Either<Failure, List<Video>>> getVideosFromChannels(
    List<String> channelIds, {
    bool forceRefresh = false,
  }) async {
    if (!forceRefresh) {
      try {
        final isCacheValid = await localDataSource.isCacheValid();
        if (isCacheValid) {
          final cachedVideos = await localDataSource.getCachedVideos();
          if (cachedVideos.isNotEmpty) {
            return Right(cachedVideos.map((m) => m.toEntity()).toList());
          }
        }
      } on CacheException {
        // Cache read failed, proceed to fetch from remote
      }
    }

    try {
      final remoteVideos = await remoteDataSource.getVideosFromChannels(channelIds);
      await localDataSource.cacheVideos(remoteVideos);
      return Right(remoteVideos.map((m) => m.toEntity()).toList());
    } on ServerException catch (e) {
      if (!forceRefresh) {
        try {
          final cachedVideos = await localDataSource.getCachedVideos();
          if (cachedVideos.isNotEmpty) {
            return Right(cachedVideos.map((m) => m.toEntity()).toList());
          }
        } on CacheException {
          // Both remote and cache failed
        }
      }
      return Left(Failure.server(e.message));
    } catch (e) {
      return Left(Failure.unexpected('An unexpected error occurred: $e'));
    }
  }

  @override
  Future<Either<Failure, List<Video>>> getVideosByChannel(String channelName) async {
    try {
      final videos = await localDataSource.getVideosByChannel(channelName);
      return Right(videos.map((m) => m.toEntity()).toList());
    } catch (e) {
      return Left(Failure.cache('Failed to get videos from cache: $e'));
    }
  }

  @override
  Future<Either<Failure, List<Video>>> getVideosByCountry(String country) async {
    try {
      final videos = await localDataSource.getVideosByCountry(country);
      return Right(videos.map((m) => m.toEntity()).toList());
    } catch (e) {
      return Left(Failure.cache('Failed to get videos from cache: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> clearCache() async {
    try {
      await localDataSource.clearCache();
      return const Right(null);
    } catch (e) {
      return Left(Failure.cache('Failed to clear cache: $e'));
    }
  }
}
