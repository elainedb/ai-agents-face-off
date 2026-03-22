import 'dart:convert';
import 'package:path/path.dart';
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
  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDb();
    return _database!;
  }

  Future<Database> _initDb() async {
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
        await db.execute('CREATE INDEX idx_channel_title ON videos (channel_title)');
        await db.execute('CREATE INDEX idx_country ON videos (country)');
        await db.execute('CREATE INDEX idx_published_at ON videos (published_at)');
        await db.execute('CREATE INDEX idx_cached_at ON videos (cached_at)');
      },
    );
  }

  @override
  Future<List<VideoModel>> getCachedVideos() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'videos',
      orderBy: 'published_at DESC',
    );

    return maps.map((map) => _mapToModel(map)).toList();
  }

  @override
  Future<void> cacheVideos(List<VideoModel> videos) async {
    final db = await database;
    final batch = db.batch();
    
    // Clear table before caching new data
    batch.delete('videos');
    
    final cachedAt = DateTime.now().millisecondsSinceEpoch;

    for (final video in videos) {
      batch.insert('videos', {
        'id': video.id,
        'title': video.title,
        'channel_title': video.channelName,
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

    await batch.commit(noResult: true);
  }

  @override
  Future<bool> isCacheValid({Duration maxAge = const Duration(hours: 24)}) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'videos',
      columns: ['cached_at'],
      limit: 1,
      orderBy: 'cached_at DESC',
    );

    if (maps.isEmpty) return false;

    final lastCachedAtRaw = maps.first['cached_at'];
    final int lastCachedAt;
    if (lastCachedAtRaw is int) {
      lastCachedAt = lastCachedAtRaw;
    } else if (lastCachedAtRaw is String) {
      lastCachedAt = int.tryParse(lastCachedAtRaw) ?? 0;
    } else {
      lastCachedAt = 0;
    }
    final now = DateTime.now().millisecondsSinceEpoch;
    return (now - lastCachedAt) < maxAge.inMilliseconds;
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
      id: map['id']?.toString() ?? '',
      title: map['title']?.toString() ?? '',
      channelName: map['channel_title']?.toString() ?? '',
      thumbnailUrl: map['thumbnail_url']?.toString() ?? '',
      publishedAt: map['published_at']?.toString() ?? '',
      tags: map['tags'] != null
          ? List<String>.from(json.decode(map['tags'].toString()))
          : [],
      city: map['city']?.toString(),
      country: map['country']?.toString(),
      latitude: map['latitude'] != null ? (map['latitude'] as num).toDouble() : null,
      longitude: map['longitude'] != null ? (map['longitude'] as num).toDouble() : null,
      recordingDate: map['recording_date']?.toString(),
    );
  }
}
