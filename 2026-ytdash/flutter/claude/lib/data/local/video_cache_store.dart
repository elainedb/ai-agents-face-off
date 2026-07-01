import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/video.dart';

/// Local persistence for the last-good video list (constitution §1.5: the local store is the
/// source of truth the UI reads from; the network only refreshes it).
class VideoCacheStore {
  static const _key = 'cached_videos_json';

  Future<void> save(List<Video> videos) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonStr = jsonEncode(videos.map((v) => v.toJson()).toList());
    await prefs.setString(_key, jsonStr);
  }

  Future<List<Video>?> load() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonStr = prefs.getString(_key);
    if (jsonStr == null) return null;
    try {
      final list = jsonDecode(jsonStr) as List;
      return list
          .map((e) => Video.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (_) {
      return null;
    }
  }
}
