import 'package:path/path.dart' as path;
import 'package:sqflite/sqflite.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/error/exceptions.dart';
import '../models/video_model.dart';

abstract class VideosLocalDataSource {
  Future<List<VideoModel>> getCachedVideos();
  Future<void> cacheVideos(List<VideoModel> videos);
  Future<bool> isCacheValid({Duration maxAge = const Duration(hours: 24)});
  Future<List<VideoModel>> getVideosByChannel(String channelName);
  Future<List<VideoModel>> getVideosByCountry(String country);
  Future<void> clearCache();
}

@LazySingleton(as: VideosLocalDataSource)
class VideosLocalDataSourceImpl implements VideosLocalDataSource {
  Database? _database;

  Future<Database> get _db async {
    if (_database != null) {
      return _database!;
    }

    _database = await openDatabase(
      path.join(await getDatabasesPath(), 'videos.db'),
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE videos (
            id TEXT PRIMARY KEY,
            title TEXT NOT NULL,
            channel_title TEXT NOT NULL,
            thumbnail_url TEXT NOT NULL,
            published_at TEXT NOT NULL,
            tags TEXT NOT NULL,
            city TEXT,
            country TEXT,
            latitude REAL,
            longitude REAL,
            recording_date TEXT,
            cached_at TEXT NOT NULL
          )
        ''');
        await db.execute(
          'CREATE INDEX idx_videos_channel_title ON videos(channel_title)',
        );
        await db.execute('CREATE INDEX idx_videos_country ON videos(country)');
        await db.execute(
          'CREATE INDEX idx_videos_published_at ON videos(published_at)',
        );
        await db.execute(
          'CREATE INDEX idx_videos_cached_at ON videos(cached_at)',
        );
      },
    );
    return _database!;
  }

  @override
  Future<void> cacheVideos(List<VideoModel> videos) async {
    try {
      final db = await _db;
      final batch = db.batch();
      final cachedAt = DateTime.now().toUtc();
      batch.delete('videos');
      for (final video in videos) {
        batch.insert('videos', video.toDbMap(cachedAt));
      }
      await batch.commit(noResult: true);
    } catch (error) {
      throw CacheException('Failed to cache videos: $error');
    }
  }

  @override
  Future<void> clearCache() async {
    try {
      final db = await _db;
      await db.delete('videos');
    } catch (error) {
      throw CacheException('Failed to clear cache: $error');
    }
  }

  @override
  Future<List<VideoModel>> getCachedVideos() async {
    try {
      final db = await _db;
      final rows = await db.query('videos', orderBy: 'published_at DESC');
      return rows.map(VideoModel.fromDbMap).toList();
    } catch (error) {
      throw CacheException('Failed to read cached videos: $error');
    }
  }

  @override
  Future<List<VideoModel>> getVideosByChannel(String channelName) async {
    try {
      final db = await _db;
      final rows = await db.query(
        'videos',
        where: 'channel_title = ?',
        whereArgs: <Object?>[channelName],
        orderBy: 'published_at DESC',
      );
      return rows.map(VideoModel.fromDbMap).toList();
    } catch (error) {
      throw CacheException('Failed to query videos by channel: $error');
    }
  }

  @override
  Future<List<VideoModel>> getVideosByCountry(String country) async {
    try {
      final db = await _db;
      final rows = await db.query(
        'videos',
        where: 'country = ?',
        whereArgs: <Object?>[country],
        orderBy: 'published_at DESC',
      );
      return rows.map(VideoModel.fromDbMap).toList();
    } catch (error) {
      throw CacheException('Failed to query videos by country: $error');
    }
  }

  @override
  Future<bool> isCacheValid({
    Duration maxAge = const Duration(hours: 24),
  }) async {
    try {
      final db = await _db;
      final rows = await db.query(
        'videos',
        columns: <String>['cached_at'],
        orderBy: 'cached_at DESC',
        limit: 1,
      );
      if (rows.isEmpty) {
        return false;
      }

      final cachedAt = DateTime.tryParse(
        rows.first['cached_at'] as String? ?? '',
      );
      if (cachedAt == null) {
        return false;
      }

      return DateTime.now().toUtc().difference(cachedAt) <= maxAge;
    } catch (error) {
      throw CacheException('Failed to validate cache: $error');
    }
  }
}
