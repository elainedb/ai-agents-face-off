import 'dart:convert';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/error/exceptions.dart';
import '../models/video_model.dart';

abstract class VideosLocalDataSource {
  Future<List<VideoModel>> getCachedVideos();
  Future<void> cacheVideos(List<VideoModel> videos);
  Future<void> clearCache();
  Future<bool> isCacheValid({Duration maxAge = const Duration(hours: 24)});
  Future<List<VideoModel>> getVideosByChannel(String channelName);
  Future<List<VideoModel>> getVideosByCountry(String country);
}

@LazySingleton(as: VideosLocalDataSource)
class VideosLocalDataSourceImpl implements VideosLocalDataSource {
  Database? _database;

  Future<Database> get database async {
    _database ??= await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final databasesPath = await getDatabasesPath();
    final path = join(databasesPath, 'videos.db');

    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDatabase,
    );
  }

  Future<void> _createDatabase(Database db, int version) async {
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

    // Create indexes for better query performance
    await db.execute('CREATE INDEX idx_channel_title ON videos(channel_title)');
    await db.execute('CREATE INDEX idx_country ON videos(country)');
    await db.execute('CREATE INDEX idx_published_at ON videos(published_at)');
    await db.execute('CREATE INDEX idx_cached_at ON videos(cached_at)');
  }

  @override
  Future<List<VideoModel>> getCachedVideos() async {
    try {
      final db = await database;
      final List<Map<String, dynamic>> maps = await db.query(
        'videos',
        orderBy: 'published_at DESC',
      );

      return maps.map((map) => _mapToVideoModel(map)).toList();
    } catch (e) {
      throw CacheException('Failed to get cached videos: ${e.toString()}');
    }
  }

  @override
  Future<void> cacheVideos(List<VideoModel> videos) async {
    try {
      final db = await database;
      final batch = db.batch();

      // Clear existing cache
      batch.delete('videos');

      // Insert new videos
      final now = DateTime.now().toIso8601String();
      for (final video in videos) {
        batch.insert('videos', _videoModelToMap(video, now));
      }

      await batch.commit(noResult: true);
    } catch (e) {
      throw CacheException('Failed to cache videos: ${e.toString()}');
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

  @override
  Future<bool> isCacheValid({Duration maxAge = const Duration(hours: 24)}) async {
    try {
      final db = await database;
      final List<Map<String, dynamic>> result = await db.query(
        'videos',
        columns: ['cached_at'],
        limit: 1,
        orderBy: 'cached_at DESC',
      );

      if (result.isEmpty) return false;

      final cachedAt = DateTime.parse(result.first['cached_at'] as String);
      final now = DateTime.now();
      return now.difference(cachedAt) < maxAge;
    } catch (e) {
      throw CacheException('Failed to check cache validity: ${e.toString()}');
    }
  }

  @override
  Future<List<VideoModel>> getVideosByChannel(String channelName) async {
    try {
      final db = await database;
      final List<Map<String, dynamic>> maps = await db.query(
        'videos',
        where: 'channel_title = ?',
        whereArgs: [channelName],
        orderBy: 'published_at DESC',
      );

      return maps.map((map) => _mapToVideoModel(map)).toList();
    } catch (e) {
      throw CacheException('Failed to get videos by channel: ${e.toString()}');
    }
  }

  @override
  Future<List<VideoModel>> getVideosByCountry(String country) async {
    try {
      final db = await database;
      final List<Map<String, dynamic>> maps = await db.query(
        'videos',
        where: 'country = ?',
        whereArgs: [country],
        orderBy: 'published_at DESC',
      );

      return maps.map((map) => _mapToVideoModel(map)).toList();
    } catch (e) {
      throw CacheException('Failed to get videos by country: ${e.toString()}');
    }
  }

  VideoModel _mapToVideoModel(Map<String, dynamic> map) {
    return VideoModel(
      id: map['id'] as String,
      title: map['title'] as String,
      channelTitle: map['channel_title'] as String,
      thumbnailUrl: map['thumbnail_url'] as String,
      publishedAt: map['published_at'] as String,
      tags: _deserializeTags(map['tags'] as String),
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
      'tags': _serializeTags(video.tags),
      'city': video.city,
      'country': video.country,
      'latitude': video.latitude,
      'longitude': video.longitude,
      'recording_date': video.recordingDate,
      'cached_at': cachedAt,
    };
  }

  String _serializeTags(List<String> tags) {
    return jsonEncode(tags);
  }

  List<String> _deserializeTags(String tagsJson) {
    try {
      final List<dynamic> decoded = jsonDecode(tagsJson);
      return decoded.cast<String>();
    } catch (e) {
      return [];
    }
  }
}