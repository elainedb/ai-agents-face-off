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
  final VideosRemoteDataSource remoteDataSource;
  final VideosLocalDataSource localDataSource;

  VideosRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
  });

  @override
  Future<Either<Failure, List<Video>>> getVideosFromChannels(List<String> channelIds, {bool forceRefresh = false}) async {
    if (!forceRefresh) {
      try {
        final isValid = await localDataSource.isCacheValid();
        if (isValid) {
          final cachedVideos = await localDataSource.getCachedVideos();
          if (cachedVideos.isNotEmpty) {
            return Right(cachedVideos.map((m) => m.toEntity()).toList());
          }
        }
      } catch (e) {
        // Fallback to fetch from remote
      }
    }

    try {
      final remoteVideos = await remoteDataSource.getVideosFromChannels(channelIds);
      await localDataSource.cacheVideos(remoteVideos);
      return Right(remoteVideos.map((m) => m.toEntity()).toList());
    } on ServerException catch (e) {
      try {
        final cachedVideos = await localDataSource.getCachedVideos();
        if (cachedVideos.isNotEmpty) {
          return Right(cachedVideos.map((m) => m.toEntity()).toList());
        }
        return Left(Failure.server(e.message));
      } catch (_) {
        return Left(Failure.server(e.message));
      }
    } catch (e) {
      return Left(Failure.unexpected(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<Video>>> getVideosByChannel(String channelName) async {
    try {
      final localVideos = await localDataSource.getVideosByChannel(channelName);
      return Right(localVideos.map((m) => m.toEntity()).toList());
    } catch (e) {
      return Left(Failure.cache(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<Video>>> getVideosByCountry(String country) async {
    try {
      final localVideos = await localDataSource.getVideosByCountry(country);
      return Right(localVideos.map((m) => m.toEntity()).toList());
    } catch (e) {
      return Left(Failure.cache(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> clearCache() async {
    try {
      await localDataSource.clearCache();
      return const Right(null);
    } catch (e) {
      return Left(Failure.cache(e.toString()));
    }
  }
}
