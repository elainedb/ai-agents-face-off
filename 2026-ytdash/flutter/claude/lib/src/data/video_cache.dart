import 'package:shared_preferences/shared_preferences.dart';

import '../domain/video.dart';

/// Local persistence for the last-known-good video list. This is the single
/// source of truth the UI falls back to when the network is unavailable
/// (constitution §1.5, AC-CACHE-01). Persisted to disk so it survives a fresh
/// process launch in offline mode.
class VideoCache {
  static const _key = 'cached_videos_v1';
  static const _tsKey = 'cached_videos_ts_v1';

  Future<void> save(List<Video> videos) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, Video.encodeList(videos));
    await prefs.setInt(_tsKey, DateTime.now().millisecondsSinceEpoch);
  }

  Future<List<Video>> load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_key);
    if (raw == null || raw.isEmpty) return const [];
    try {
      return Video.decodeList(raw);
    } catch (_) {
      return const [];
    }
  }

  Future<bool> hasData() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_key);
    return raw != null && raw.isNotEmpty;
  }
}
