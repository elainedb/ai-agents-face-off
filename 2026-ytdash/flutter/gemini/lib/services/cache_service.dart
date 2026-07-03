import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/video.dart';

class CacheService {
  static const String _videosKey = 'cached_videos';

  Future<void> saveVideos(List<Video> videos) async {
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      final List<Map<String, dynamic>> list = videos.map((v) => v.toJson()).toList();
      await prefs.setString(_videosKey, jsonEncode(list));
    } catch (e) {
      print('Error saving videos to cache: $e');
    }
  }

  Future<List<Video>> getVideos() async {
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      final String? jsonStr = prefs.getString(_videosKey);
      if (jsonStr != null && jsonStr.isNotEmpty) {
        final List<dynamic> decoded = jsonDecode(jsonStr) as List<dynamic>;
        return decoded.map((item) => Video.fromJson(item as Map<String, dynamic>)).toList();
      }
    } catch (e) {
      print('Error loading videos from cache: $e');
    }
    return [];
  }

  Future<void> clearCache() async {
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.remove(_videosKey);
    } catch (e) {
      print('Error clearing cache: $e');
    }
  }
}
