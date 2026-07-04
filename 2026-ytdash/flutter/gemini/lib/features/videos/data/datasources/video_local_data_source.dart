import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../domain/models/video.dart';

class VideoLocalDataSource {
  final SharedPreferences sharedPreferences;

  VideoLocalDataSource({required this.sharedPreferences});

  static const _cacheKey = 'CACHED_VIDEOS';

  Future<void> cacheVideos(List<Video> videos) async {
    final jsonList = videos.map((v) => v.toJson()).toList();
    await sharedPreferences.setString(_cacheKey, json.encode(jsonList));
  }

  Future<List<Video>> getCachedVideos() async {
    final jsonString = sharedPreferences.getString(_cacheKey);
    if (jsonString != null) {
      final jsonList = json.decode(jsonString) as List<dynamic>;
      return jsonList
          .map((e) => Video.fromJson(e as Map<String, dynamic>))
          .toList();
    } else {
      return [];
    }
  }
}
