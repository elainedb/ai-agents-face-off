import 'dart:convert';

import 'package:flutter/services.dart' show rootBundle;

import '../local/video_cache_store.dart';
import '../models/channel.dart';
import '../models/video.dart';
import '../remote/youtube_api_client.dart';
import 'video_repository.dart';

class VideoRepositoryImpl implements VideoRepository {
  VideoRepositoryImpl({required this.apiClient, VideoCacheStore? cacheStore})
    : _cache = cacheStore ?? VideoCacheStore();

  final YoutubeApiClient apiClient;
  final VideoCacheStore _cache;

  List<SourceChannel>? _channelsCache;

  Future<List<SourceChannel>> _loadChannels() async {
    final cached = _channelsCache;
    if (cached != null) return cached;
    final raw = await rootBundle.loadString('config/channels.json');
    final list = jsonDecode(raw) as List;
    final channels = list
        .map((e) => SourceChannel.fromJson(e as Map<String, dynamic>))
        .toList();
    _channelsCache = channels;
    return channels;
  }

  @override
  Future<List<Video>> fetchVideos() async {
    final channels = await _loadChannels();
    try {
      final videos = await apiClient.fetchAllVideos(channels);
      await _cache.save(videos);
      return videos;
    } catch (e) {
      final cached = await _cache.load();
      if (cached != null) return cached;
      rethrow;
    }
  }
}
