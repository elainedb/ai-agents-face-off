import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/video.dart';

/// Persistent local store — the single source of truth the UI reads from
/// (constitution §1.5). A plain JSON blob in SharedPreferences survives process
/// death, which is what makes the offline-relaunch test (AC-CACHE-01) work.
class VideoCache {
  static const String _key = 'cached_videos_v1';

  Future<void> save(List<Video> videos) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = jsonEncode(videos.map((v) => v.toJson()).toList());
    await prefs.setString(_key, raw);
  }

  Future<List<Video>> load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_key);
    if (raw == null || raw.isEmpty) return [];
    try {
      final list = jsonDecode(raw) as List;
      return list
          .map((e) => Video.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (_) {
      return [];
    }
  }

  Future<bool> hasData() async => (await load()).isNotEmpty;
}
