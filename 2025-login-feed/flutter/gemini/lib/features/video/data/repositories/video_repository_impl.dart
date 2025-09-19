import 'package:dartz/dartz.dart';
import 'package:flutter_gemini/core/errors/failures.dart';
import 'package:flutter_gemini/features/video/data/datasources/video_remote_data_source.dart';
import 'package:flutter_gemini/features/video/data/models/video_model.dart';
import 'package:flutter_gemini/features/video/domain/entities/video.dart';
import 'package:flutter_gemini/features/video/domain/repositories/video_repository.dart';
import 'package:injectable/injectable.dart';

@LazySingleton(as: VideoRepository)
class VideoRepositoryImpl implements VideoRepository {
  final VideoRemoteDataSource remoteDataSource;

  VideoRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, List<Video>>> getVideos() async {
    try {
      final remoteVideos = await remoteDataSource.getVideos();
      final videos = remoteVideos.map((e) => e.toEntity()).where((e) => e != null).cast<Video>().toList();
      videos.sort((a, b) => b.publishedAt.compareTo(a.publishedAt));
      return Right(videos);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
