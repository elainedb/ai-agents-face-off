import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ytdash_flutter/data/models/video.dart';

class CacheService {
  static const _key = 'cached_videos';

  Future<void> saveVideos(List<Video> videos) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonList = videos.map((v) => v.toJson()).toList();
      await prefs.setString(_key, jsonEncode(jsonList));
    } catch (e) {
      print('Error saving videos to cache: $e');
    }
  }

  Future<List<Video>> loadVideos() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = prefs.getString(_key);
      if (jsonString != null && jsonString.isNotEmpty) {
        final List<dynamic> jsonList = jsonDecode(jsonString) as List<dynamic>;
        return jsonList
            .map((item) => Video.fromJson(item as Map<String, dynamic>))
            .toList();
      }
    } catch (e) {
      print('Error loading videos from cache: $e');
    }
    return [];
  }

  Future<void> clear() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_key);
    } catch (e) {
      print('Error clearing cache: $e');
    }
  }
}
