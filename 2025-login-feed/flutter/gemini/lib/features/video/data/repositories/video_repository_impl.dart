import 'package:dartz/dartz.dart';
import 'package:flutter_gemini/core/errors/exceptions.dart';
import 'package:flutter_gemini/core/errors/failures.dart';
import 'package:flutter_gemini/features/video/data/datasources/video_local_data_source.dart';
import 'package:flutter_gemini/features/video/data/datasources/video_remote_data_source.dart';
import 'package:flutter_gemini/features/video/domain/entities/video.dart';
import 'package:flutter_gemini/features/video/domain/repositories/video_repository.dart';
import 'package:injectable/injectable.dart';

@LazySingleton(as: VideoRepository)
class VideoRepositoryImpl implements VideoRepository {
  final VideoRemoteDataSource remoteDataSource;
  final VideoLocalDataSource localDataSource;

  VideoRepositoryImpl(this.remoteDataSource, this.localDataSource);

  @override
  Future<Either<Failure, List<Video>>> getVideos(
      {bool forceRefresh = false}) async {
    print('--- VideoRepository: getVideos called with forceRefresh: $forceRefresh');
    try {
      if (!forceRefresh) {
        final localVideos = await localDataSource.getVideos();
        if (localVideos.isNotEmpty) {
          print('--- VideoRepository: Returning data from cache.');
          return Right(localVideos);
        }
      } else {
        print('--- VideoRepository: Clearing cache due to forceRefresh.');
        await localDataSource.clearVideos();
      }
      print('--- VideoRepository: Fetching data from remote source.');
      final remoteVideos = await remoteDataSource.getVideos();
      await localDataSource.cacheVideos(remoteVideos);
      return Right(remoteVideos);
    } on ServerException {
      return Left(const ServerFailure('Server Error'));
    } on CacheException {
      return Left(const CacheFailure('Cache Error'));
    }
  }
}