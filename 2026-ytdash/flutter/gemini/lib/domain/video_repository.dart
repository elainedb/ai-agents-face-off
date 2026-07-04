import 'dart:convert';
import 'package:flutter/services.dart';
import '../domain/models.dart';
import '../data/youtube_api.dart';
import '../data/cache_repository.dart';

class VideoRepository {
  final YouTubeApi _api;
  final CacheRepository _cache;

  VideoRepository(this._api, this._cache);

  Future<List<ChannelConfig>> getChannelConfigs() async {
    final jsonString = await rootBundle.loadString('config/channels.json');
    final List<dynamic> jsonList = json.decode(jsonString);
    return jsonList.map((e) => ChannelConfig.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<List<Video>> getVideos({bool forceRefresh = false}) async {
    if (!forceRefresh) {
      final cached = await _cache.getVideos();
      if (cached != null && cached.isNotEmpty) {
        return cached;
      }
    }

    try {
      final channels = await getChannelConfigs();
      final videos = await _api.fetchAllVideos(channels);
      await _cache.saveVideos(videos);
      return videos;
    } catch (e) {
      // Fallback to cache if network fails, even on force refresh
      final cached = await _cache.getVideos();
      if (cached != null && cached.isNotEmpty) {
        return cached;
      }
      rethrow;
    }
  }
}
