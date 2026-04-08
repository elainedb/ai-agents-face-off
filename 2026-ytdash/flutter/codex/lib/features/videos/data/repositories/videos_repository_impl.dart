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
  const VideosRepositoryImpl(this._remoteDataSource, this._localDataSource);

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
      return Left(Failure.unexpected(error.toString()));
    }
  }

  @override
  Future<Either<Failure, List<Video>>> getVideosByChannel(String channelName) async {
    try {
      final models = await _localDataSource.getVideosByChannel(channelName);
      return Right(models.map((video) => video.toEntity()).toList());
    } on CacheException catch (error) {
      return Left(Failure.cache(error.message));
    } catch (error) {
      return Left(Failure.unexpected(error.toString()));
    }
  }

  @override
  Future<Either<Failure, List<Video>>> getVideosByCountry(String country) async {
    try {
      final models = await _localDataSource.getVideosByCountry(country);
      return Right(models.map((video) => video.toEntity()).toList());
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
      if (!forceRefresh) {
        final isValid = await _localDataSource.isCacheValid();
        final cachedVideos = await _localDataSource.getCachedVideos();
        if (isValid && cachedVideos.isNotEmpty) {
          return Right(cachedVideos.map((video) => video.toEntity()).toList());
        }
      }

      final remoteVideos = await _remoteDataSource.getVideosFromChannels(channelIds);
      await _localDataSource.cacheVideos(remoteVideos);
      return Right(remoteVideos.map((video) => video.toEntity()).toList());
    } on ServerException catch (error) {
      try {
        final cachedVideos = await _localDataSource.getCachedVideos();
        if (cachedVideos.isNotEmpty) {
          return Right(cachedVideos.map((video) => video.toEntity()).toList());
        }
      } catch (_) {}
      return Left(Failure.server(error.message));
    } on CacheException catch (error) {
      return Left(Failure.cache(error.message));
    } catch (error) {
      return Left(Failure.unexpected(error.toString()));
    }
  }
}
