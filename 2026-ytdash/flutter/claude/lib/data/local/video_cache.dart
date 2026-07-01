import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../../domain/models/video.dart';

/// The local persistence layer — the single source of truth the UI reads from
/// (constitution §1.5). The network only ever refreshes this store.
class VideoCache {
  VideoCache({SharedPreferencesAsync? prefs})
    : _prefs = prefs ?? SharedPreferencesAsync();

  static const _key = 'cached_videos_v1';

  final SharedPreferencesAsync _prefs;

  Future<List<Video>> read() async {
    final raw = await _prefs.getString(_key);
    if (raw == null || raw.isEmpty) return const [];
    final list = jsonDecode(raw) as List<dynamic>;
    return list.cast<Map<String, dynamic>>().map(Video.fromJson).toList();
  }

  Future<void> write(List<Video> videos) async {
    final encoded = jsonEncode(videos.map((v) => v.toJson()).toList());
    await _prefs.setString(_key, encoded);
  }

  Future<void> clear() => _prefs.remove(_key);
}
