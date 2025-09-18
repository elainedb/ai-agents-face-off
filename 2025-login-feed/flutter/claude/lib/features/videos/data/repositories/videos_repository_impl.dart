import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/video.dart';
import '../../domain/repositories/videos_repository.dart';
import '../datasources/videos_remote_datasource.dart';

@LazySingleton(as: VideosRepository)
class VideosRepositoryImpl implements VideosRepository {
  final VideosRemoteDataSource remoteDataSource;

  VideosRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, List<Video>>> getVideosFromChannels(
    List<String> channelIds,
  ) async {
    try {
      final videoModels = await remoteDataSource.getVideosFromChannels(channelIds);
      final videos = videoModels.map((model) => model.toEntity()).toList();
      return Right(videos);
    } on ServerException catch (e) {
      return Left(Failure.server(e.message));
    } catch (e) {
      return Left(Failure.unexpected(e.toString()));
    }
  }
}