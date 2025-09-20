import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/video.dart';
import '../../domain/repositories/videos_repository.dart';
import '../datasources/videos_remote_datasource.dart';
import '../datasources/videos_local_datasource.dart';

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
    try {
      // Check cache validity first (unless force refresh is requested)
      if (!forceRefresh && await localDataSource.isCacheValid()) {
        final cachedVideos = await localDataSource.getCachedVideos();
        if (cachedVideos.isNotEmpty) {
          final videos = cachedVideos.map((model) => model.toEntity()).toList();
          return Right(videos);
        }
      }

      // Fetch from remote source
      final videoModels = await remoteDataSource.getVideosFromChannels(channelIds);

      // Cache the results
      await localDataSource.cacheVideos(videoModels);

      // Return the entities
      final videos = videoModels.map((model) => model.toEntity()).toList();
      return Right(videos);
    } on ServerException catch (e) {
      // Try to return cached data if remote fails
      try {
        final cachedVideos = await localDataSource.getCachedVideos();
        if (cachedVideos.isNotEmpty) {
          final videos = cachedVideos.map((model) => model.toEntity()).toList();
          return Right(videos);
        }
      } catch (_) {
        // Ignore cache errors when remote already failed
      }
      return Left(Failure.server(e.message));
    } on CacheException catch (e) {
      return Left(Failure.cache(e.message));
    } catch (e) {
      return Left(Failure.unexpected(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<Video>>> getVideosByChannel(String channelName) async {
    try {
      final videoModels = await localDataSource.getVideosByChannel(channelName);
      final videos = videoModels.map((model) => model.toEntity()).toList();
      return Right(videos);
    } on CacheException catch (e) {
      return Left(Failure.cache(e.message));
    } catch (e) {
      return Left(Failure.unexpected(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<Video>>> getVideosByCountry(String country) async {
    try {
      final videoModels = await localDataSource.getVideosByCountry(country);
      final videos = videoModels.map((model) => model.toEntity()).toList();
      return Right(videos);
    } on CacheException catch (e) {
      return Left(Failure.cache(e.message));
    } catch (e) {
      return Left(Failure.unexpected(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> clearCache() async {
    try {
      await localDataSource.clearCache();
      return const Right(null);
    } on CacheException catch (e) {
      return Left(Failure.cache(e.message));
    } catch (e) {
      return Left(Failure.unexpected(e.toString()));
    }
  }
}