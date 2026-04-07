import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:ytdash_flutter_claude/core/error/exceptions.dart';
import 'package:ytdash_flutter_claude/core/error/failures.dart';
import 'package:ytdash_flutter_claude/features/videos/data/datasources/videos_local_data_source.dart';
import 'package:ytdash_flutter_claude/features/videos/data/datasources/videos_remote_data_source.dart';
import 'package:ytdash_flutter_claude/features/videos/domain/entities/video.dart';
import 'package:ytdash_flutter_claude/features/videos/domain/repositories/videos_repository.dart';

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
        final cacheValid = await localDataSource.isCacheValid();
        if (cacheValid) {
          final cached = await localDataSource.getCachedVideos();
          if (cached.isNotEmpty) {
            return Right(cached.map((m) => m.toEntity()).toList());
          }
        }
      } catch (_) {}
    }

    try {
      final remoteVideos =
          await remoteDataSource.getVideosFromChannels(channelIds);
      await localDataSource.cacheVideos(remoteVideos);
      return Right(remoteVideos.map((m) => m.toEntity()).toList());
    } on ServerException catch (e) {
      try {
        final cached = await localDataSource.getCachedVideos();
        if (cached.isNotEmpty) {
          return Right(cached.map((m) => m.toEntity()).toList());
        }
      } catch (_) {}
      return Left(Failure.server(e.message));
    } catch (e) {
      return Left(Failure.unexpected('Unexpected error: $e'));
    }
  }

  @override
  Future<Either<Failure, List<Video>>> getVideosByChannel(
      String channelName) async {
    try {
      final videos = await localDataSource.getVideosByChannel(channelName);
      return Right(videos.map((m) => m.toEntity()).toList());
    } on CacheException catch (e) {
      return Left(Failure.cache(e.message));
    } catch (e) {
      return Left(Failure.unexpected('Unexpected error: $e'));
    }
  }

  @override
  Future<Either<Failure, List<Video>>> getVideosByCountry(
      String country) async {
    try {
      final videos = await localDataSource.getVideosByCountry(country);
      return Right(videos.map((m) => m.toEntity()).toList());
    } on CacheException catch (e) {
      return Left(Failure.cache(e.message));
    } catch (e) {
      return Left(Failure.unexpected('Unexpected error: $e'));
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
      return Left(Failure.unexpected('Unexpected error: $e'));
    }
  }
}
