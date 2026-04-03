import 'dart:convert';
import 'package:injectable/injectable.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
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

  Future _createDB(Database db, int version) async {
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

  VideoModel _fromMap(Map<String, dynamic> map) {
    return VideoModel(
      id: map['id'] as String,
      title: map['title'] as String,
      channelTitle: map['channel_title'] as String,
      thumbnailUrl: map['thumbnail_url'] as String,
      publishedAt: map['published_at'] as String,
      tags: List<String>.from(json.decode(map['tags'] as String)),
      city: map['city'] as String?,
      country: map['country'] as String?,
      latitude: map['latitude'] as double?,
      longitude: map['longitude'] as double?,
      recordingDate: map['recording_date'] as String?,
    );
  }

  @override
  Future<List<VideoModel>> getCachedVideos() async {
    final db = await database;
    final maps = await db.query('videos', orderBy: 'published_at DESC');
    if (maps.isEmpty) {
      throw CacheException('No cached videos found');
    }
    return maps.map((map) => _fromMap(map)).toList();
  }

  @override
  Future<void> cacheVideos(List<VideoModel> videos) async {
    final db = await database;
    final cachedAt = DateTime.now().toIso8601String();
    
    await db.transaction((txn) async {
      await txn.delete('videos');
      for (final video in videos) {
        await txn.insert('videos', {
          'id': video.id,
          'title': video.title,
          'channel_title': video.channelTitle,
          'thumbnail_url': video.thumbnailUrl,
          'published_at': video.publishedAt,
          'tags': json.encode(video.tags),
          'city': video.city,
          'country': video.country,
          'latitude': video.latitude,
          'longitude': video.longitude,
          'recording_date': video.recordingDate,
          'cached_at': cachedAt,
        });
      }
    });
  }

  @override
  Future<bool> isCacheValid({Duration maxAge = const Duration(hours: 24)}) async {
    final db = await database;
    final maps = await db.query('videos', columns: ['cached_at'], limit: 1);
    if (maps.isEmpty) return false;
    
    final cachedAtStr = maps.first['cached_at'] as String;
    final cachedAt = DateTime.parse(cachedAtStr);
    return DateTime.now().difference(cachedAt) < maxAge;
  }

  @override
  Future<List<VideoModel>> getVideosByChannel(String channelName) async {
    final db = await database;
    final maps = await db.query(
      'videos',
      where: 'channel_title = ?',
      whereArgs: [channelName],
      orderBy: 'published_at DESC',
    );
    if (maps.isEmpty) {
      throw CacheException('No cached videos found for channel');
    }
    return maps.map((map) => _fromMap(map)).toList();
  }

  @override
  Future<List<VideoModel>> getVideosByCountry(String country) async {
    final db = await database;
    final maps = await db.query(
      'videos',
      where: 'country = ?',
      whereArgs: [country],
      orderBy: 'published_at DESC',
    );
    if (maps.isEmpty) {
      throw CacheException('No cached videos found for country');
    }
    return maps.map((map) => _fromMap(map)).toList();
  }

  @override
  Future<void> clearCache() async {
    final db = await database;
    await db.delete('videos');
  }
}
