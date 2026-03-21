import 'dart:convert';
import 'package:injectable/injectable.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

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
  static const _dbName = 'videos.db';
  static const _tableName = 'videos';

  Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB();
    return _database!;
  }

  Future<Database> _initDB() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, _dbName);

    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE $_tableName (
            id TEXT PRIMARY KEY,
            title TEXT,
            channel_title TEXT,
            thumbnail_url TEXT,
            published_at TEXT,
            tags TEXT,
            city TEXT,
            country TEXT,
            latitude REAL,
            longitude REAL,
            recording_date TEXT,
            cached_at TEXT
          )
        ''');
        await db.execute('CREATE INDEX idx_channel_title ON $_tableName(channel_title)');
        await db.execute('CREATE INDEX idx_country ON $_tableName(country)');
        await db.execute('CREATE INDEX idx_published_at ON $_tableName(published_at)');
        await db.execute('CREATE INDEX idx_cached_at ON $_tableName(cached_at)');
      },
    );
  }

  @override
  Future<List<VideoModel>> getCachedVideos() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      _tableName,
      orderBy: 'published_at DESC',
    );

    return maps.map((map) => _mapToModel(map)).toList();
  }

  @override
  Future<void> cacheVideos(List<VideoModel> videos) async {
    final db = await database;
    final cachedAt = DateTime.now().toIso8601String();

    await db.transaction((txn) async {
      await txn.delete(_tableName);
      for (final video in videos) {
        final map = _modelToMap(video);
        map['cached_at'] = cachedAt;
        await txn.insert(_tableName, map);
      }
    });
  }

  @override
  Future<bool> isCacheValid({Duration maxAge = const Duration(hours: 24)}) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      _tableName,
      columns: ['cached_at'],
      orderBy: 'cached_at DESC',
      limit: 1,
    );

    if (maps.isEmpty) return false;

    final cachedAtString = maps.first['cached_at'] as String?;
    if (cachedAtString == null) return false;

    final cachedAt = DateTime.parse(cachedAtString);
    final now = DateTime.now();

    return now.difference(cachedAt) < maxAge;
  }

  @override
  Future<List<VideoModel>> getVideosByChannel(String channelName) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      _tableName,
      where: 'channel_title = ?',
      whereArgs: [channelName],
      orderBy: 'published_at DESC',
    );
    return maps.map((map) => _mapToModel(map)).toList();
  }

  @override
  Future<List<VideoModel>> getVideosByCountry(String country) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      _tableName,
      where: 'country = ?',
      whereArgs: [country],
      orderBy: 'published_at DESC',
    );
    return maps.map((map) => _mapToModel(map)).toList();
  }

  @override
  Future<void> clearCache() async {
    final db = await database;
    await db.delete(_tableName);
  }

  VideoModel _mapToModel(Map<String, dynamic> map) {
    return VideoModel(
      id: map['id'] as String,
      title: map['title'] as String,
      channelTitle: map['channel_title'] as String,
      thumbnailUrl: map['thumbnail_url'] as String,
      publishedAt: map['published_at'] as String,
      tags: (json.decode(map['tags'] as String) as List).map((e) => e as String).toList(),
      city: map['city'] as String?,
      country: map['country'] as String?,
      latitude: map['latitude'] as double?,
      longitude: map['longitude'] as double?,
      recordingDate: map['recording_date'] as String?,
    );
  }

  Map<String, dynamic> _modelToMap(VideoModel model) {
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
    };
  }
}
