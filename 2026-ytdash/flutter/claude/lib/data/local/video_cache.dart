import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../../domain/entities/video.dart';

/// The local store that is the single source of truth the UI reads from (constitution §1.5): a
/// network refresh replaces this on success; a network failure falls back to whatever is here.
class VideoCache {
  static const _key = 'ytdash_video_cache_v1';

  Future<List<Video>> read() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_key);
    if (raw == null || raw.isEmpty) return const [];
    try {
      final list = jsonDecode(raw) as List<dynamic>;
      return list
          .map((e) => Video.fromJson(e as Map<String, dynamic>))
          .toList(growable: false);
    } catch (_) {
      return const [];
    }
  }

  Future<void> write(List<Video> videos) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = jsonEncode(videos.map((v) => v.toJson()).toList());
    await prefs.setString(_key, raw);
  }

  Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_key);
  }
}
