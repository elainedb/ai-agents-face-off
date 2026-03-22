import 'dart:convert';
import 'package:injectable/injectable.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:ytdash_flutter_gemini/features/videos/data/models/video_model.dart';
import 'package:ytdash_flutter_gemini/core/error/exceptions.dart';

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

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('videos.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
    );
  }

  Future<void> _createDB(Database db, int version) async {
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
    await db.execute('CREATE INDEX idx_channel_title ON videos (channel_title)');
    await db.execute('CREATE INDEX idx_country ON videos (country)');
    await db.execute('CREATE INDEX idx_published_at ON videos (published_at)');
    await db.execute('CREATE INDEX idx_cached_at ON videos (cached_at)');
  }

  VideoModel _fromDb(Map<String, dynamic> row) {
    return VideoModel(
      id: row['id'] as String,
      title: row['title'] as String,
      channelTitle: row['channel_title'] as String,
      thumbnailUrl: row['thumbnail_url'] as String,
      publishedAt: row['published_at'] as String,
      tags: List<String>.from(json.decode(row['tags'] as String)),
      city: row['city'] as String?,
      country: row['country'] as String?,
      latitude: row['latitude'] as double?,
      longitude: row['longitude'] as double?,
      recordingDate: row['recording_date'] as String?,
    );
  }

  Map<String, dynamic> _toDb(VideoModel model, String cachedAt) {
    return {
      'id': model.id,
      'title': model.title,
      'channel_title': model.channelTitle,
      'thumbnail_url': model.thumbnailUrl,
      'published_at': model.publishedAt,
      'tags': json.encode(model.tags),
      'city': model.city,
      'country': model.country,
      'latitude': model.latitude,
      'longitude': model.longitude,
      'recording_date': model.recordingDate,
      'cached_at': cachedAt,
    };
  }

  @override
  Future<List<VideoModel>> getCachedVideos() async {
    final db = await database;
    final result = await db.query('videos', orderBy: 'published_at DESC');
    if (result.isEmpty) {
      throw CacheException('No cached videos found');
    }
    return result.map((row) => _fromDb(row)).toList();
  }

  @override
  Future<void> cacheVideos(List<VideoModel> videos) async {
    final db = await database;
    final cachedAt = DateTime.now().toIso8601String();
    
    await db.transaction((txn) async {
      await txn.delete('videos');
      final batch = txn.batch();
      for (final video in videos) {
        batch.insert('videos', _toDb(video, cachedAt));
      }
      await batch.commit(noResult: true);
    });
  }

  @override
  Future<bool> isCacheValid({Duration maxAge = const Duration(hours: 24)}) async {
    final db = await database;
    final result = await db.query(
      'videos',
      columns: ['cached_at'],
      limit: 1,
    );
    if (result.isEmpty) return false;

    final cachedAtStr = result.first['cached_at'] as String;
    final cachedAt = DateTime.parse(cachedAtStr);
    return DateTime.now().difference(cachedAt) < maxAge;
  }

  @override
  Future<List<VideoModel>> getVideosByChannel(String channelName) async {
    final db = await database;
    final result = await db.query(
      'videos',
      where: 'channel_title = ?',
      whereArgs: [channelName],
      orderBy: 'published_at DESC',
    );
    return result.map((row) => _fromDb(row)).toList();
  }

  @override
  Future<List<VideoModel>> getVideosByCountry(String country) async {
    final db = await database;
    final result = await db.query(
      'videos',
      where: 'country = ?',
      whereArgs: [country],
      orderBy: 'published_at DESC',
    );
    return result.map((row) => _fromDb(row)).toList();
  }

  @override
  Future<void> clearCache() async {
    final db = await database;
    await db.delete('videos');
  }
}
