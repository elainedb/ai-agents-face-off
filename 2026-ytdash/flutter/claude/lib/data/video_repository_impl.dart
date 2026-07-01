import 'dart:convert';

import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/app_config.dart';
import '../domain/entities/video.dart';
import '../domain/repositories/video_repository.dart';
import 'local/video_cache.dart';
import 'remote/youtube_api_client.dart';
import 'remote/youtube_dtos.dart';

/// Network-first, stale-cache-fallback implementation. There is no catch-all channel query (see
/// `spec/youtube-api.md`), so this fetches each configured channel individually, follows pagination
/// on every one, merges + dedupes by id, then enriches with `videos.list` for location.
class VideoRepositoryImpl implements VideoRepository {
  VideoRepositoryImpl({required AppConfig config, VideoCache? cache})
    : _config = config,
      _cache = cache ?? VideoCache();

  final AppConfig _config;
  final VideoCache _cache;
  List<ChannelConfig>? _channelsCache;

  Future<List<ChannelConfig>> _loadChannels() async {
    final cached = _channelsCache;
    if (cached != null) return cached;
    final raw = await rootBundle.loadString('config/channels.json');
    final list = jsonDecode(raw) as List<dynamic>;
    final channels = list
        .map((e) => e as Map<String, dynamic>)
        .map(
          (e) =>
              ChannelConfig(id: e['id'] as String, label: e['label'] as String),
        )
        .toList(growable: false);
    _channelsCache = channels;
    return channels;
  }

  @override
  Future<List<Video>> cached() => _cache.read();

  @override
  Future<VideoResult> refresh() async {
    try {
      final channels = await _loadChannels();
      final client = YoutubeApiClient(
        baseUrl: _config.apiBaseUrl,
        apiKey: _config.apiKey,
      );

      // Fetch ALL pages of EVERY configured channel — there is no catch-all endpoint.
      final perChannelItems = await Future.wait(
        channels.map(client.fetchAllForChannel),
      );
      final allItems = perChannelItems
          .expand((items) => items)
          .toList(growable: false);

      final ids = allItems
          .map((i) => i.id)
          .where((id) => id.isNotEmpty)
          .toSet()
          .toList();
      final details = await client.fetchDetails(ids);

      final videos = mergeToVideos(allItems, details);
      await _cache.write(videos);
      return VideoResultOk(videos, fromCache: false);
    } catch (e) {
      final stale = await _cache.read();
      if (stale.isNotEmpty) {
        return VideoResultOk(stale, fromCache: true);
      }
      return VideoResultError(e.toString());
    }
  }
}

final videoRepositoryProvider = Provider<VideoRepository>((ref) {
  final config = ref.watch(appConfigProvider);
  return VideoRepositoryImpl(config: config);
});
