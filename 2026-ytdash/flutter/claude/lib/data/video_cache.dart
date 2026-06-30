import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import 'models/video.dart';

/// On-disk cache (constitution §1.5: the local store is the source of truth; the network refreshes
/// it). Persisted to SharedPreferences so an offline *fresh-process* relaunch (AC-CACHE-01) still
/// has data. Replace-on-refresh + stale-fallback is the speced behavior.
class VideoCache {
  static const String _key = 'ytdash.cached_videos.v1';

  Future<void> save(List<Video> videos) async {
    final prefs = await SharedPreferences.getInstance();
    final encoded = jsonEncode(videos.map((v) => v.toJson()).toList());
    await prefs.setString(_key, encoded);
  }

  Future<List<Video>> load() async {
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
}
