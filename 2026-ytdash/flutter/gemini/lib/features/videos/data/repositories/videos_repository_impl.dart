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
  Future<Either<Failure, List<Video>>> getVideosFromChannels(
    List<String> channelIds, {
    bool forceRefresh = false,
  }) async {
    try {
      if (!forceRefresh) {
        final isValid = await localDataSource.isCacheValid();
        if (isValid) {
          try {
            final cached = await localDataSource.getCachedVideos();
            if (cached.isNotEmpty) {
              return Right(cached.map((m) => m.toEntity()).toList());
            }
          } catch (_) {
            // Proceed to remote if cache fails or is empty
          }
        }
      }

      final remoteVideos = await remoteDataSource.getVideosFromChannels(channelIds);
      await localDataSource.cacheVideos(remoteVideos);
      return Right(remoteVideos.map((m) => m.toEntity()).toList());
    } on ServerException catch (e) {
      try {
        final cached = await localDataSource.getCachedVideos();
        if (cached.isNotEmpty) {
          return Right(cached.map((m) => m.toEntity()).toList());
        }
      } catch (_) {
        // Fallthrough
      }
      return Left(Failure.server(e.message));
    } catch (e) {
      return Left(Failure.unexpected('An unexpected error occurred: $e'));
    }
  }

  @override
  Future<Either<Failure, List<Video>>> getVideosByChannel(String channelName) async {
    try {
      final cached = await localDataSource.getVideosByChannel(channelName);
      return Right(cached.map((m) => m.toEntity()).toList());
    } on CacheException catch (e) {
      return Left(Failure.cache(e.message));
    } catch (e) {
      return Left(Failure.unexpected('An unexpected error occurred: $e'));
    }
  }

  @override
  Future<Either<Failure, List<Video>>> getVideosByCountry(String country) async {
    try {
      final cached = await localDataSource.getVideosByCountry(country);
      return Right(cached.map((m) => m.toEntity()).toList());
    } on CacheException catch (e) {
      return Left(Failure.cache(e.message));
    } catch (e) {
      return Left(Failure.unexpected('An unexpected error occurred: $e'));
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
