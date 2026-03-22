import 'package:dartz/dartz.dart';

import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/video.dart';
import '../../domain/repositories/videos_repository.dart';
import '../datasources/videos_local_data_source.dart';
import '../datasources/videos_remote_data_source.dart';

class VideosRepositoryImpl implements VideosRepository {
  VideosRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
  });

  final VideosRemoteDataSource remoteDataSource;
  final VideosLocalDataSource localDataSource;

  @override
  Future<Either<Failure, void>> clearCache() async {
    try {
      await localDataSource.clearCache();
      return const Right(null);
    } on CacheException catch (error) {
      return Left(Failure.cache(error.message));
    } catch (error) {
      return Left(Failure.unexpected(error.toString()));
    }
  }

  @override
  Future<Either<Failure, List<Video>>> getVideosByChannel(
    String channelName,
  ) async {
    try {
      final videos = await localDataSource.getVideosByChannel(channelName);
      return Right(videos.map((item) => item.toEntity()).toList());
    } on CacheException catch (error) {
      return Left(Failure.cache(error.message));
    } catch (error) {
      return Left(Failure.unexpected(error.toString()));
    }
  }

  @override
  Future<Either<Failure, List<Video>>> getVideosByCountry(
    String country,
  ) async {
    try {
      final videos = await localDataSource.getVideosByCountry(country);
      return Right(videos.map((item) => item.toEntity()).toList());
    } on CacheException catch (error) {
      return Left(Failure.cache(error.message));
    } catch (error) {
      return Left(Failure.unexpected(error.toString()));
    }
  }

  @override
  Future<Either<Failure, List<Video>>> getVideosFromChannels(
    List<String> channelIds, {
    bool forceRefresh = false,
  }) async {
    try {
      final cacheValid = !forceRefresh && await localDataSource.isCacheValid();
      if (cacheValid) {
        final cached = await localDataSource.getCachedVideos();
        if (cached.isNotEmpty) {
          return Right(cached.map((item) => item.toEntity()).toList());
        }
      }

      final remoteVideos = await remoteDataSource.getVideosFromChannels(
        channelIds,
      );
      await localDataSource.cacheVideos(remoteVideos);
      return Right(remoteVideos.map((item) => item.toEntity()).toList());
    } on ServerException catch (error) {
      try {
        final cached = await localDataSource.getCachedVideos();
        if (cached.isNotEmpty) {
          return Right(cached.map((item) => item.toEntity()).toList());
        }
      } catch (_) {
        // Ignore cache fallback errors and return the original server failure.
      }
      return Left(Failure.server(error.message));
    } on CacheException catch (error) {
      return Left(Failure.cache(error.message));
    } catch (error) {
      return Left(Failure.unexpected(error.toString()));
    }
  }
}
