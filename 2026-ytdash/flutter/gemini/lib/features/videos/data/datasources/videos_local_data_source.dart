import 'dart:convert';
import 'package:injectable/injectable.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/video_model.dart';

@lazySingleton
class VideosLocalDataSource {
  Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB();
    return _database!;
  }

  Future<Database> _initDB() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'videos.db');

    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
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
        await db.execute('CREATE INDEX idx_channel_title ON videos(channel_title)');
        await db.execute('CREATE INDEX idx_country ON videos(country)');
        await db.execute('CREATE INDEX idx_published_at ON videos(published_at)');
        await db.execute('CREATE INDEX idx_cached_at ON videos(cached_at)');
      },
    );
  }

  Future<List<VideoModel>> getCachedVideos() async {
    final db = await database;
    final maps = await db.query('videos', orderBy: 'published_at DESC');
    return maps.map((m) => _fromMap(m)).toList();
  }

  Future<void> cacheVideos(List<VideoModel> videos) async {
    final db = await database;
    final now = DateTime.now().millisecondsSinceEpoch;
    
    await db.transaction((txn) async {
      await txn.delete('videos');
      for (var video in videos) {
        await txn.insert('videos', _toMap(video, now));
      }
    });
  }

  Future<bool> isCacheValid({Duration maxAge = const Duration(hours: 24)}) async {
    final db = await database;
    final result = await db.query('videos', columns: ['cached_at'], limit: 1);
    if (result.isEmpty) return false;
    
    final cachedAt = result.first['cached_at'] as int;
    final cachedTime = DateTime.fromMillisecondsSinceEpoch(cachedAt);
    return DateTime.now().difference(cachedTime) < maxAge;
  }

  Future<List<VideoModel>> getVideosByChannel(String channelName) async {
    final db = await database;
    final maps = await db.query('videos', where: 'channel_title = ?', whereArgs: [channelName]);
    return maps.map((m) => _fromMap(m)).toList();
  }

  Future<List<VideoModel>> getVideosByCountry(String country) async {
    final db = await database;
    final maps = await db.query('videos', where: 'country = ?', whereArgs: [country]);
    return maps.map((m) => _fromMap(m)).toList();
  }

  Future<void> clearCache() async {
    final db = await database;
    await db.delete('videos');
  }

  Map<String, dynamic> _toMap(VideoModel model, int cachedAt) {
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
}
