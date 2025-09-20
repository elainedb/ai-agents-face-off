import 'dart:convert';

import 'package:flutter_gemini/core/errors/exceptions.dart';
import 'package:flutter_gemini/features/video/data/datasources/video_local_data_source.dart';
import 'package:flutter_gemini/features/video/data/models/video_model.dart';
import 'package:injectable/injectable.dart';
import 'package:sqflite/sqflite.dart';

@LazySingleton(as: VideoLocalDataSource)
class VideoLocalDataSourceImpl implements VideoLocalDataSource {
  final Database database;

  VideoLocalDataSourceImpl(this.database);

  @override
  Future<void> cacheVideos(List<VideoModel> videos) async {
    try {
      final batch = database.batch();
      for (final video in videos) {
        batch.insert(
          'videos',
          {
            'id': video.id,
            'video': jsonEncode(video.toJson()),
            'timestamp': DateTime.now().millisecondsSinceEpoch,
          },
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      }
      await batch.apply();
    } catch (e) {
      throw CacheException();
    }
  }

  @override
  Future<List<VideoModel>> getVideos() async {
    try {
      final maps = await database.query('videos');
      if (maps.isNotEmpty) {
        return maps
            .map((map) =>
                VideoModel.fromJson(jsonDecode(map['video'] as String)))
            .toList();
      }
      return [];
    } catch (e) {
      throw CacheException();
    }
  }

  @override
  Future<void> clearVideos() async {
    try {
      print('--- VideoLocalDataSource: Clearing all videos from the database.');
      await database.delete('videos');
    } catch (e) {
      throw CacheException();
    }
  }
}