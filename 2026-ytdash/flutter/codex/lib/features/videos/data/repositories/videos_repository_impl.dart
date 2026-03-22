import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/video.dart';
import '../../domain/repositories/videos_repository.dart';
import '../datasources/videos_local_data_source.dart';
import '../datasources/videos_remote_data_source.dart';

@LazySingleton(as: VideosRepository)
class VideosRepositoryImpl implements VideosRepository {
  VideosRepositoryImpl(this._remoteDataSource, this._localDataSource);

  final VideosRemoteDataSource _remoteDataSource;
  final VideosLocalDataSource _localDataSource;

  @override
  Future<Either<Failure, void>> clearCache() async {
    try {
      await _localDataSource.clearCache();
      return const Right(null);
    } on CacheException catch (error) {
      return Left(Failure.cache(error.message));
    } catch (error) {
      return Left(Failure.unexpected('Unexpected cache error: $error'));
    }
  }

  @override
  Future<Either<Failure, List<Video>>> getVideosByChannel(
    String channelName,
  ) async {
    try {
      final videos = await _localDataSource.getVideosByChannel(channelName);
      return Right(videos.map((video) => video.toEntity()).toList());
    } on CacheException catch (error) {
      return Left(Failure.cache(error.message));
    } catch (error) {
      return Left(Failure.unexpected('Unexpected cache error: $error'));
    }
  }

  @override
  Future<Either<Failure, List<Video>>> getVideosByCountry(
    String country,
  ) async {
    try {
      final videos = await _localDataSource.getVideosByCountry(country);
      return Right(videos.map((video) => video.toEntity()).toList());
    } on CacheException catch (error) {
      return Left(Failure.cache(error.message));
    } catch (error) {
      return Left(Failure.unexpected('Unexpected cache error: $error'));
    }
  }

  @override
  Future<Either<Failure, List<Video>>> getVideosFromChannels(
    List<String> channelIds, {
    bool forceRefresh = false,
  }) async {
    try {
      final hasValidCache =
          !forceRefresh && await _localDataSource.isCacheValid();
      if (hasValidCache) {
        final cachedVideos = await _localDataSource.getCachedVideos();
        if (cachedVideos.isNotEmpty) {
          return Right(cachedVideos.map((video) => video.toEntity()).toList());
        }
      }

      final remoteVideos = await _remoteDataSource.getVideosFromChannels(
        channelIds,
      );
      await _localDataSource.cacheVideos(remoteVideos);
      return Right(remoteVideos.map((video) => video.toEntity()).toList());
    } on ServerException catch (error) {
      try {
        final cachedVideos = await _localDataSource.getCachedVideos();
        if (cachedVideos.isNotEmpty) {
          return Right(cachedVideos.map((video) => video.toEntity()).toList());
        }
      } on CacheException {
        return Left(Failure.server(error.message));
      }
      return Left(Failure.server(error.message));
    } on CacheException catch (error) {
      return Left(Failure.cache(error.message));
    } catch (error) {
      return Left(Failure.unexpected('Unexpected videos error: $error'));
    }
  }
}
