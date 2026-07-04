import 'dart:convert';
import 'package:injectable/injectable.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../domain/entities/video.dart';

abstract class VideoLocalDataSource {
  Future<void> cacheVideos(List<Video> videos);
  Future<List<Video>> getCachedVideos();
}

@LazySingleton(as: VideoLocalDataSource)
class VideoLocalDataSourceImpl implements VideoLocalDataSource {
  final SharedPreferences prefs;
  static const CACHE_KEY = 'CACHED_VIDEOS';

  VideoLocalDataSourceImpl(this.prefs);

  @override
  Future<void> cacheVideos(List<Video> videos) async {
    final List<Map<String, dynamic>> jsonList = videos.map((v) => {
      'id': v.id,
      'title': v.title,
      'description': v.description,
      'publishedAt': v.publishedAt.toIso8601String(),
      'category': v.category,
      'thumbnailUrl': v.thumbnailUrl,
      'duration': v.duration,
      'lat': v.lat,
      'lng': v.lng,
    }).toList();
    
    await prefs.setString(CACHE_KEY, json.encode(jsonList));
  }

  @override
  Future<List<Video>> getCachedVideos() async {
    final jsonString = prefs.getString(CACHE_KEY);
    if (jsonString != null) {
      final List<dynamic> jsonList = json.decode(jsonString);
      return jsonList.map((json) => Video(
        id: json['id'],
        title: json['title'],
        description: json['description'],
        publishedAt: DateTime.parse(json['publishedAt']),
        category: json['category'],
        thumbnailUrl: json['thumbnailUrl'],
        duration: json['duration'] ?? '',
        lat: json['lat']?.toDouble(),
        lng: json['lng']?.toDouble(),
      )).toList();
    }
    return [];
  }
}
