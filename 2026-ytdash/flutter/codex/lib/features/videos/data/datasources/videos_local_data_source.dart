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

  Future<Database> get _db async {
    if (_database != null) {
      return _database!;
    }
    _database = await _openDatabase();
    return _database!;
  }

  Future<Database> _openDatabase() async {
    final databasesPath = await getDatabasesPath();
    return openDatabase(
      path.join(databasesPath, 'videos.db'),
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE videos(
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
            cached_at INTEGER NOT NULL
          )
        ''');
        await db.execute(
          'CREATE INDEX idx_videos_channel ON videos(channel_title)',
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
  }

  @override
  Future<void> cacheVideos(List<VideoModel> videos) async {
    try {
      final db = await _db;
      final now = DateTime.now().millisecondsSinceEpoch;
      final batch = db.batch();
      batch.delete('videos');
      for (final video in videos) {
        batch.insert(
          'videos',
          video.toMap(cachedAt: now),
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      }
      await batch.commit(noResult: true);
    } catch (error) {
      throw CacheException('Failed to cache videos. $error');
    }
  }

  @override
  Future<void> clearCache() async {
    try {
      final db = await _db;
      await db.delete('videos');
    } catch (error) {
      throw CacheException('Failed to clear cache. $error');
    }
  }

  @override
  Future<List<VideoModel>> getCachedVideos() async {
    try {
      final db = await _db;
      final rows = await db.query('videos', orderBy: 'published_at DESC');
      return rows.map(VideoModel.fromMap).toList();
    } catch (error) {
      throw CacheException('Failed to read cached videos. $error');
    }
  }

  @override
  Future<List<VideoModel>> getVideosByChannel(String channelName) async {
    try {
      final db = await _db;
      final rows = await db.query(
        'videos',
        where: 'channel_title = ?',
        whereArgs: [channelName],
        orderBy: 'published_at DESC',
      );
      return rows.map(VideoModel.fromMap).toList();
    } catch (error) {
      throw CacheException('Failed to filter videos by channel. $error');
    }
  }

  @override
  Future<List<VideoModel>> getVideosByCountry(String country) async {
    try {
      final db = await _db;
      final rows = await db.query(
        'videos',
        where: 'country = ?',
        whereArgs: [country],
        orderBy: 'published_at DESC',
      );
      return rows.map(VideoModel.fromMap).toList();
    } catch (error) {
      throw CacheException('Failed to filter videos by country. $error');
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
        columns: ['cached_at'],
        orderBy: 'cached_at DESC',
        limit: 1,
      );
      if (rows.isEmpty) {
        return false;
      }
      final cachedAt = rows.first['cached_at'] as int;
      final age = DateTime.now().difference(
        DateTime.fromMillisecondsSinceEpoch(cachedAt),
      );
      return age <= maxAge;
    } catch (error) {
      throw CacheException('Failed to validate cache. $error');
    }
  }
}
