import 'dart:convert';
import 'package:dartz/dartz.dart';
import 'package:flutter/services.dart';
import 'package:injectable/injectable.dart';

import '../../core/error/failure.dart';
import '../../domain/entities/channel.dart';
import '../../domain/entities/video.dart';
import '../../domain/repositories/video_repository.dart';
import '../datasources/video_local_data_source.dart';
import '../datasources/video_remote_data_source.dart';

@LazySingleton(as: VideoRepository)
class VideoRepositoryImpl implements VideoRepository {
  final VideoRemoteDataSource remoteDataSource;
  final VideoLocalDataSource localDataSource;

  VideoRepositoryImpl(this.remoteDataSource, this.localDataSource);

  Future<List<Channel>> _getChannels() async {
    final String response = await rootBundle.loadString('config/channels.json');
    final data = json.decode(response) as List<dynamic>;
    return data.map((e) => Channel(id: e['id'], label: e['label'])).toList();
  }

  @override
  Future<Either<Failure, List<Video>>> getVideos() async {
    print('GET VIDEOS STARTED');
    try {
      final channels = await _getChannels();
      print('CHANNELS LOADED: ${channels.length}');
      final remoteVideos = await remoteDataSource.getVideos(channels);
      print('REMOTE VIDEOS FETCHED: ${remoteVideos.length}');
      await localDataSource.cacheVideos(remoteVideos);
      print('REMOTE VIDEOS CACHED');
      return Right(remoteVideos);
    } catch (e) {
      print('GET VIDEOS ERROR: $e');
      final cachedVideos = await localDataSource.getCachedVideos();
      if (cachedVideos.isNotEmpty) {
        return Right(cachedVideos); // Stale-fallback
      }
      return Left(ServerFailure(e.toString()));
    }
  }
}
