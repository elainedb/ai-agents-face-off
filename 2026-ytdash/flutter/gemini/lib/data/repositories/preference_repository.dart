import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../domain/models/video.dart';

class PreferenceRepository {
  static const _keyUserEmail = 'user_email';
  static const _keyCachedVideos = 'cached_videos';

  Future<void> saveUserEmail(String? email) async {
    final prefs = await SharedPreferences.getInstance();
    if (email == null) {
      await prefs.remove(_keyUserEmail);
    } else {
      await prefs.setString(_keyUserEmail, email);
    }
  }

  Future<String?> getUserEmail() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyUserEmail);
  }

  Future<void> saveCachedVideos(List<Video> videos) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonList = videos.map((v) => v.toJson()).toList();
    final jsonString = jsonEncode(jsonList);
    await prefs.setString(_keyCachedVideos, jsonString);
  }

  Future<List<Video>> getCachedVideos() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_keyCachedVideos);
    if (jsonString == null) return [];
    try {
      final List<dynamic> jsonList = jsonDecode(jsonString) as List<dynamic>;
      return jsonList.map((j) => Video.fromJson(jsonModelToMap(j))).toList();
    } catch (_) {
      return [];
    }
  }

  Future<void> clearSession() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyUserEmail);
  }

  // Safe helper to convert JSON dynamic map to Map<String, dynamic>
  static Map<String, dynamic> jsonModelToMap(dynamic json) {
    if (json is Map<String, dynamic>) return json;
    return Map<String, dynamic>.from(json as Map);
  }
}
