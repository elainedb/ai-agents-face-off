import 'package:path/path.dart' as path;
import 'package:sqflite/sqflite.dart';

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

class VideosLocalDataSourceImpl implements VideosLocalDataSource {
  Database? _database;

  Future<Database> get database async {
    if (_database != null) {
      return _database!;
    }

    _database = await openDatabase(
      path.join(await getDatabasesPath(), 'videos.db'),
      version: 1,
      onCreate: (Database db, int version) async {
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
      final Database db = await database;
      final Batch batch = db.batch();
      final String cachedAt = DateTime.now().toUtc().toIso8601String();
      batch.delete('videos');
      for (final VideoModel video in videos) {
        batch.insert('videos', video.toMap(cachedAt: cachedAt));
      }
      await batch.commit(noResult: true);
    } catch (error) {
      throw CacheException('Unable to cache videos: $error');
    }
  }

  @override
  Future<void> clearCache() async {
    try {
      final Database db = await database;
      await db.delete('videos');
    } catch (error) {
      throw CacheException('Unable to clear cache: $error');
    }
  }

  @override
  Future<List<VideoModel>> getCachedVideos() async {
    try {
      final Database db = await database;
      final List<Map<String, Object?>> rows = await db.query(
        'videos',
        orderBy: 'published_at DESC',
      );
      return rows.map(VideoModel.fromMap).toList();
    } catch (error) {
      throw CacheException('Unable to load cached videos: $error');
    }
  }

  @override
  Future<List<VideoModel>> getVideosByChannel(String channelName) async {
    try {
      final Database db = await database;
      final List<Map<String, Object?>> rows = await db.query(
        'videos',
        where: 'channel_title = ?',
        whereArgs: <Object?>[channelName],
        orderBy: 'published_at DESC',
      );
      return rows.map(VideoModel.fromMap).toList();
    } catch (error) {
      throw CacheException('Unable to filter videos by channel: $error');
    }
  }

  @override
  Future<List<VideoModel>> getVideosByCountry(String country) async {
    try {
      final Database db = await database;
      final List<Map<String, Object?>> rows = await db.query(
        'videos',
        where: 'country = ?',
        whereArgs: <Object?>[country],
        orderBy: 'published_at DESC',
      );
      return rows.map(VideoModel.fromMap).toList();
    } catch (error) {
      throw CacheException('Unable to filter videos by country: $error');
    }
  }

  @override
  Future<bool> isCacheValid({
    Duration maxAge = const Duration(hours: 24),
  }) async {
    try {
      final Database db = await database;
      final List<Map<String, Object?>> rows = await db.query(
        'videos',
        columns: <String>['cached_at'],
        orderBy: 'cached_at DESC',
        limit: 1,
      );
      if (rows.isEmpty) {
        return false;
      }
      final DateTime cachedAt = DateTime.parse(
        rows.first['cached_at']! as String,
      );
      return DateTime.now().toUtc().difference(cachedAt) <= maxAge;
    } catch (error) {
      throw CacheException('Unable to validate cache: $error');
    }
  }
}
