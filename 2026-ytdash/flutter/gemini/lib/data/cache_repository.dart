import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../domain/models.dart';

class CacheRepository {
  static const String _cacheKey = 'ytdash_videos_cache';
  static const String _timestampKey = 'ytdash_cache_timestamp';
  static const Duration _ttl = Duration(hours: 24);

  Future<void> saveVideos(List<Video> videos) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonList = videos.map((v) => v.toJson()).toList();
    await prefs.setString(_cacheKey, json.encode(jsonList));
    await prefs.setInt(_timestampKey, DateTime.now().millisecondsSinceEpoch);
  }

  Future<List<Video>?> getVideos() async {
    final prefs = await SharedPreferences.getInstance();
    final cacheString = prefs.getString(_cacheKey);
    final timestamp = prefs.getInt(_timestampKey);

    if (cacheString == null || timestamp == null) {
      return null;
    }

    final cacheTime = DateTime.fromMillisecondsSinceEpoch(timestamp);
    if (DateTime.now().difference(cacheTime) > _ttl) {
      // Return null or stale cache?
      // Constitution: "stale-fallback on network error".
      // We will return it, but the caller will try to fetch from network first if it's stale.
      // Actually, wait: we can always return the cached videos, and the caller decides if it should refresh.
      // But let's just return what's there.
    }

    try {
      final jsonList = json.decode(cacheString) as List<dynamic>;
      return jsonList.map((e) => Video.fromJson(e as Map<String, dynamic>)).toList();
    } catch (_) {
      return null;
    }
  }
}
