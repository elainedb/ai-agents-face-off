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
  }

  @override
  Future<List<VideoModel>> getCachedVideos() async {
    final db = await database;
    final maps = await db.query('videos', orderBy: 'published_at DESC');
    return maps.map((map) => _fromDbMap(map)).toList();
  }

  @override
  Future<void> cacheVideos(List<VideoModel> videos) async {
    final db = await database;
    final timestamp = DateTime.now().millisecondsSinceEpoch;

    await db.transaction((txn) async {
      await txn.delete('videos');
      
      final batch = txn.batch();
      for (final video in videos) {
        batch.insert('videos', _toDbMap(video, timestamp));
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
      orderBy: 'cached_at DESC',
      limit: 1,
    );

    if (result.isEmpty) return false;

    final cachedAtValue = result.first['cached_at'];
    final cachedAtMs = cachedAtValue is int ? cachedAtValue : int.tryParse(cachedAtValue?.toString() ?? '') ?? 0;
    final cachedTime = DateTime.fromMillisecondsSinceEpoch(cachedAtMs);
    return DateTime.now().difference(cachedTime) < maxAge;
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
    return maps.map((map) => _fromDbMap(map)).toList();
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
    return maps.map((map) => _fromDbMap(map)).toList();
  }

  @override
  Future<void> clearCache() async {
    final db = await database;
    await db.delete('videos');
  }

  Map<String, dynamic> _toDbMap(VideoModel video, int cachedAt) {
    return {
      'id': video.id,
      'title': video.title,
      'channel_title': video.channelTitle,
      'thumbnail_url': video.thumbnailUrl,
      'published_at': video.publishedAt,
      'tags': jsonEncode(video.tags),
      'city': video.city,
      'country': video.country,
      'latitude': video.latitude,
      'longitude': video.longitude,
      'recording_date': video.recordingDate,
      'cached_at': cachedAt,
    };
  }

  VideoModel _fromDbMap(Map<String, dynamic> map) {
    return VideoModel(
      id: map['id'] as String,
      title: map['title'] as String,
      channelTitle: map['channel_title'] as String,
      thumbnailUrl: map['thumbnail_url'] as String,
      publishedAt: map['published_at'] as String,
      tags: List<String>.from(jsonDecode(map['tags'] as String)),
      city: map['city'] as String?,
      country: map['country'] as String?,
      latitude: (map['latitude'] as num?)?.toDouble(),
      longitude: (map['longitude'] as num?)?.toDouble(),
      recordingDate: map['recording_date'] as String?,
    );
  }
}
