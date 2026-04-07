import 'package:path/path.dart' as p;
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
    _database ??= await openDatabase(
      p.join(await getDatabasesPath(), 'videos.db'),
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
        await db.execute('CREATE INDEX idx_videos_cached_at ON videos(cached_at)');
      },
    );
    return _database!;
  }

  @override
  Future<void> cacheVideos(List<VideoModel> videos) async {
    final db = await _db;
    final batch = db.batch();
    final now = DateTime.now().toUtc().toIso8601String();

    batch.delete('videos');
    for (final video in videos) {
      batch.insert('videos', video.toDbMap(cachedAt: now));
    }
    await batch.commit(noResult: true);
  }

  @override
  Future<void> clearCache() async {
    final db = await _db;
    await db.delete('videos');
  }

  @override
  Future<List<VideoModel>> getCachedVideos() async {
    try {
      final db = await _db;
      final rows = await db.query(
        'videos',
        orderBy: 'published_at DESC',
      );
      return rows.map(VideoModel.fromDbMap).toList();
    } catch (error) {
      throw CacheException('Unable to read cached videos: $error');
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
      return rows.map(VideoModel.fromDbMap).toList();
    } catch (error) {
      throw CacheException('Unable to read videos by channel: $error');
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
      return rows.map(VideoModel.fromDbMap).toList();
    } catch (error) {
      throw CacheException('Unable to read videos by country: $error');
    }
  }

  @override
  Future<bool> isCacheValid({Duration maxAge = const Duration(hours: 24)}) async {
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
    final cachedAt = DateTime.tryParse(rows.first['cached_at']! as String);
    if (cachedAt == null) {
      return false;
    }
    return DateTime.now().toUtc().difference(cachedAt) <= maxAge;
  }
}
