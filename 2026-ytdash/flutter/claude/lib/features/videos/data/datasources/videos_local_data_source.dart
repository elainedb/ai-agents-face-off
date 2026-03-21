import 'dart:convert';

import 'package:injectable/injectable.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:ytdash_flutter_claude/core/error/exceptions.dart';
import 'package:ytdash_flutter_claude/features/videos/data/models/video_model.dart';

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
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'videos.db');

    return openDatabase(
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
            cached_at TEXT
          )
        ''');
        await db.execute(
            'CREATE INDEX idx_channel_title ON videos(channel_title)');
        await db.execute('CREATE INDEX idx_country ON videos(country)');
        await db.execute('CREATE INDEX idx_published_at ON videos(published_at)');
        await db.execute('CREATE INDEX idx_cached_at ON videos(cached_at)');
      },
    );
  }

  @override
  Future<List<VideoModel>> getCachedVideos() async {
    try {
      final db = await database;
      final maps =
          await db.query('videos', orderBy: 'published_at DESC');
      return maps.map(_videoModelFromMap).toList();
    } catch (e) {
      throw CacheException('Failed to get cached videos: ${e.toString()}');
    }
  }

  @override
  Future<void> cacheVideos(List<VideoModel> videos) async {
    try {
      final db = await database;
      final batch = db.batch();
      batch.delete('videos');

      final now = DateTime.now().toIso8601String();
      for (final video in videos) {
        batch.insert('videos', _videoModelToMap(video, now),
            conflictAlgorithm: ConflictAlgorithm.replace);
      }

      await batch.commit(noResult: true);
    } catch (e) {
      throw CacheException('Failed to cache videos: ${e.toString()}');
    }
  }

  @override
  Future<bool> isCacheValid(
      {Duration maxAge = const Duration(hours: 24)}) async {
    try {
      final db = await database;
      final result = await db.rawQuery(
        'SELECT cached_at FROM videos ORDER BY cached_at DESC LIMIT 1',
      );

      if (result.isEmpty) return false;

      final cachedAt = DateTime.parse(result.first['cached_at'] as String);
      return DateTime.now().difference(cachedAt) < maxAge;
    } catch (e) {
      return false;
    }
  }

  @override
  Future<List<VideoModel>> getVideosByChannel(String channelName) async {
    try {
      final db = await database;
      final maps = await db.query(
        'videos',
        where: 'channel_title = ?',
        whereArgs: [channelName],
        orderBy: 'published_at DESC',
      );
      return maps.map(_videoModelFromMap).toList();
    } catch (e) {
      throw CacheException(
          'Failed to get videos by channel: ${e.toString()}');
    }
  }

  @override
  Future<List<VideoModel>> getVideosByCountry(String country) async {
    try {
      final db = await database;
      final maps = await db.query(
        'videos',
        where: 'country = ?',
        whereArgs: [country],
        orderBy: 'published_at DESC',
      );
      return maps.map(_videoModelFromMap).toList();
    } catch (e) {
      throw CacheException(
          'Failed to get videos by country: ${e.toString()}');
    }
  }

  @override
  Future<void> clearCache() async {
    try {
      final db = await database;
      await db.delete('videos');
    } catch (e) {
      throw CacheException('Failed to clear cache: ${e.toString()}');
    }
  }

  VideoModel _videoModelFromMap(Map<String, dynamic> map) {
    final tagsJson = map['tags'] as String?;
    final tags = tagsJson != null && tagsJson.isNotEmpty
        ? (jsonDecode(tagsJson) as List<dynamic>)
            .map((e) => e.toString())
            .toList()
        : <String>[];

    return VideoModel(
      id: map['id'] as String,
      title: map['title'] as String? ?? '',
      channelTitle: map['channel_title'] as String? ?? '',
      thumbnailUrl: map['thumbnail_url'] as String? ?? '',
      publishedAt: map['published_at'] as String? ?? '',
      tags: tags,
      city: map['city'] as String?,
      country: map['country'] as String?,
      latitude: map['latitude'] as double?,
      longitude: map['longitude'] as double?,
      recordingDate: map['recording_date'] as String?,
    );
  }

  Map<String, dynamic> _videoModelToMap(VideoModel video, String cachedAt) {
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
}
