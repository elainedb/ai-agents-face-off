import 'package:dartz/dartz.dart';

import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/video.dart';
import '../../domain/repositories/videos_repository.dart';
import '../datasources/videos_local_data_source.dart';
import '../datasources/videos_remote_data_source.dart';

class VideosRepositoryImpl implements VideosRepository {
  VideosRepositoryImpl({
    required this.localDataSource,
    required this.remoteDataSource,
  });

  final VideosLocalDataSource localDataSource;
  final VideosRemoteDataSource remoteDataSource;

  @override
  Future<Either<Failure, void>> clearCache() async {
    try {
      await localDataSource.clearCache();
      return const Right<Failure, void>(null);
    } on CacheException catch (error) {
      return Left<Failure, void>(Failure.cache(error.message));
    } catch (error) {
      return Left<Failure, void>(
        Failure.unexpected('Unexpected cache error: $error'),
      );
    }
  }

  @override
  Future<Either<Failure, List<Video>>> getVideosByChannel(
    String channelName,
  ) async {
    try {
      final videos = await localDataSource.getVideosByChannel(channelName);
      return Right<Failure, List<Video>>(
        videos.map((video) => video.toEntity()).toList(),
      );
    } on CacheException catch (error) {
      return Left<Failure, List<Video>>(Failure.cache(error.message));
    } catch (error) {
      return Left<Failure, List<Video>>(
        Failure.unexpected('Unexpected cache error: $error'),
      );
    }
  }

  @override
  Future<Either<Failure, List<Video>>> getVideosByCountry(
    String country,
  ) async {
    try {
      final videos = await localDataSource.getVideosByCountry(country);
      return Right<Failure, List<Video>>(
        videos.map((video) => video.toEntity()).toList(),
      );
    } on CacheException catch (error) {
      return Left<Failure, List<Video>>(Failure.cache(error.message));
    } catch (error) {
      return Left<Failure, List<Video>>(
        Failure.unexpected('Unexpected cache error: $error'),
      );
    }
  }

  @override
  Future<Either<Failure, List<Video>>> getVideosFromChannels(
    List<String> channelIds, {
    bool forceRefresh = false,
  }) async {
    try {
      final bool isCacheValid =
          !forceRefresh && await localDataSource.isCacheValid();
      if (isCacheValid) {
        final cached = await localDataSource.getCachedVideos();
        if (cached.isNotEmpty) {
          return Right<Failure, List<Video>>(
            cached.map((video) => video.toEntity()).toList(),
          );
        }
      }

      final remote = await remoteDataSource.getVideosFromChannels(channelIds);
      await localDataSource.cacheVideos(remote);
      return Right<Failure, List<Video>>(
        remote.map((video) => video.toEntity()).toList(),
      );
    } on ServerException catch (error) {
      try {
        final cached = await localDataSource.getCachedVideos();
        if (cached.isNotEmpty) {
          return Right<Failure, List<Video>>(
            cached.map((video) => video.toEntity()).toList(),
          );
        }
      } catch (_) {}
      return Left<Failure, List<Video>>(Failure.server(error.message));
    } on NetworkException catch (error) {
      return Left<Failure, List<Video>>(Failure.network(error.message));
    } on CacheException catch (error) {
      return Left<Failure, List<Video>>(Failure.cache(error.message));
    } catch (error) {
      return Left<Failure, List<Video>>(
        Failure.unexpected('Unexpected videos error: $error'),
      );
    }
  }
}
