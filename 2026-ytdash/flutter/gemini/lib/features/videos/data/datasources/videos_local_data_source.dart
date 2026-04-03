import 'dart:convert';
import 'package:injectable/injectable.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
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
  static Database? _database;

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
        cached_at INTEGER
      )
    ''');

    await db.execute('CREATE INDEX idx_channel_title ON videos (channel_title)');
    await db.execute('CREATE INDEX idx_country ON videos (country)');
    await db.execute('CREATE INDEX idx_published_at ON videos (published_at)');
    await db.execute('CREATE INDEX idx_cached_at ON videos (cached_at)');
  }

  @override
  Future<List<VideoModel>> getCachedVideos() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'videos',
      orderBy: 'published_at DESC',
    );

    return List.generate(maps.length, (i) {
      return VideoModel(
        id: maps[i]['id'] as String,
        title: maps[i]['title'] as String,
        channelTitle: maps[i]['channel_title'] as String,
        thumbnailUrl: maps[i]['thumbnail_url'] as String,
        publishedAt: maps[i]['published_at'] as String,
        tags: List<String>.from(json.decode(maps[i]['tags'] as String)),
        city: maps[i]['city'] as String?,
        country: maps[i]['country'] as String?,
        latitude: maps[i]['latitude'] as double?,
        longitude: maps[i]['longitude'] as double?,
        recordingDate: maps[i]['recording_date'] as String?,
      );
    });
  }

  @override
  Future<void> cacheVideos(List<VideoModel> videos) async {
    final db = await database;
    final cachedAt = DateTime.now().millisecondsSinceEpoch;

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
    final maps = await db.query(
      'videos',
      columns: ['cached_at'],
      limit: 1,
      orderBy: 'cached_at DESC',
    );

    if (maps.isEmpty) return false;

    final dynamic cachedAtData = maps.first['cached_at'];
    final cachedAt = cachedAtData is int ? cachedAtData : int.parse(cachedAtData.toString());
    final cacheDate = DateTime.fromMillisecondsSinceEpoch(cachedAt);
    return DateTime.now().difference(cacheDate) < maxAge;
  }

  @override
  Future<List<VideoModel>> getVideosByChannel(String channelName) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'videos',
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
      'videos',
      where: 'country = ?',
      whereArgs: [country],
      orderBy: 'published_at DESC',
    );

    return maps.map((map) => _mapToModel(map)).toList();
  }

  @override
  Future<void> clearCache() async {
    final db = await database;
    await db.delete('videos');
  }

  VideoModel _mapToModel(Map<String, dynamic> map) {
    return VideoModel(
      id: map['id'] as String,
      title: map['title'] as String,
      channelTitle: map['channel_title'] as String,
      thumbnailUrl: map['thumbnail_url'] as String,
      publishedAt: map['published_at'] as String,
      tags: List<String>.from(json.decode(map['tags'] as String)),
      city: map['city'] as String?,
      country: map['country'] as String?,
      latitude: (map['latitude'] as num?)?.toDouble(),
      longitude: (map['longitude'] as num?)?.toDouble(),
      recordingDate: map['recording_date'] as String?,
    );
  }
}
