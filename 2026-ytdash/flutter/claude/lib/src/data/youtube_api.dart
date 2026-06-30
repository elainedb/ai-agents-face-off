import 'dart:convert';

import 'package:http/http.dart' as http;

import '../config/app_config.dart';
import '../domain/video.dart';

/// Raised on any network/parse failure so the repository/UI can surface a
/// visible error state instead of crashing (constitution §1.6).
class ApiException implements Exception {
  ApiException(this.message);
  final String message;
  @override
  String toString() => 'ApiException: $message';
}

/// Thin client over the YouTube Data API v3 (mock or real — same signatures).
/// Aggregates every configured source channel, follows pagination to fetch
/// ALL pages, dedupes by videoId, and enriches with recording locations.
class YoutubeApi {
  YoutubeApi({
    required this.baseUrl,
    required this.apiKey,
    http.Client? client,
  }) : _client = client ?? http.Client();

  /// Host root, e.g. `http://10.0.2.2:8093` or `https://www.googleapis.com`.
  final String baseUrl;
  final String apiKey;
  final http.Client _client;

  static const int _maxPagesPerChannel = 50; // safety bound against bad tokens

  /// Fetches and aggregates all videos for [channels].
  Future<List<Video>> fetchAllVideos(List<SourceChannel> channels) async {
    final ordered = <Video>[];
    final seen = <String>{};

    for (final channel in channels) {
      final channelVideos = await _fetchChannel(channel);
      for (final v in channelVideos) {
        if (seen.add(v.id)) ordered.add(v);
      }
    }

    if (ordered.isEmpty) return ordered;

    // Enrich with recording locations via videos.list (batches of 50).
    final locations = await _fetchLocations(ordered.map((v) => v.id).toList());
    return [
      for (final v in ordered)
        if (locations.containsKey(v.id))
          v.copyWith(lat: locations[v.id]!.$1, lng: locations[v.id]!.$2)
        else
          v,
    ];
  }

  Future<List<Video>> _fetchChannel(SourceChannel channel) async {
    final out = <Video>[];
    String? pageToken;
    var pages = 0;
    do {
      final params = {
        'key': apiKey,
        'channelId': channel.id,
        'part': 'snippet',
        'order': 'date',
        'type': 'video',
        'maxResults': '50',
      };
      if (pageToken != null) params['pageToken'] = pageToken;
      final uri = _uri('/youtube/v3/search', params);
      final json = await _getJson(uri);
      final items = (json['items'] as List?) ?? const [];
      for (final raw in items) {
        final item = raw as Map<String, dynamic>;
        final id = _videoId(item);
        if (id == null) continue;
        final snippet = (item['snippet'] as Map<String, dynamic>?) ?? const {};
        out.add(Video(
          id: id,
          title: (snippet['title'] ?? '').toString(),
          description: (snippet['description'] ?? '').toString(),
          publishedAt:
              DateTime.tryParse((snippet['publishedAt'] ?? '').toString())
                      ?.toUtc() ??
                  DateTime.fromMillisecondsSinceEpoch(0, isUtc: true),
          category: channel.label,
          thumbnailUrl: _thumb(snippet),
        ));
      }
      pageToken = (json['nextPageToken'] as String?);
      pages++;
    } while (pageToken != null && pageToken.isNotEmpty && pages < _maxPagesPerChannel);
    return out;
  }

  /// Returns a map of videoId -> (lat, lng) for videos that have a location.
  Future<Map<String, (double, double)>> _fetchLocations(List<String> ids) async {
    final result = <String, (double, double)>{};
    for (var i = 0; i < ids.length; i += 50) {
      final batch = ids.sublist(i, i + 50 > ids.length ? ids.length : i + 50);
      final uri = _uri('/youtube/v3/videos', {
        'key': apiKey,
        'id': batch.join(','),
        'part': 'snippet,contentDetails,recordingDetails',
      });
      final json = await _getJson(uri);
      final items = (json['items'] as List?) ?? const [];
      for (final raw in items) {
        final item = raw as Map<String, dynamic>;
        final id = (item['id'] ?? '').toString();
        final rec = item['recordingDetails'] as Map<String, dynamic>?;
        final loc = rec?['location'] as Map<String, dynamic>?;
        final lat = (loc?['latitude'] as num?)?.toDouble();
        final lng = (loc?['longitude'] as num?)?.toDouble();
        if (id.isNotEmpty && lat != null && lng != null) {
          result[id] = (lat, lng);
        }
      }
    }
    return result;
  }

  String? _videoId(Map<String, dynamic> item) {
    final id = item['id'];
    if (id is Map && id['videoId'] != null) return id['videoId'].toString();
    // playlistItems idiom: snippet.resourceId.videoId
    final snippet = item['snippet'] as Map<String, dynamic>?;
    final resourceId = snippet?['resourceId'] as Map<String, dynamic>?;
    if (resourceId?['videoId'] != null) return resourceId!['videoId'].toString();
    if (id is String && id.isNotEmpty) return id;
    return null;
  }

  String _thumb(Map<String, dynamic> snippet) {
    final thumbs = snippet['thumbnails'] as Map<String, dynamic>?;
    final medium = thumbs?['medium'] as Map<String, dynamic>?;
    final high = thumbs?['high'] as Map<String, dynamic>?;
    final def = thumbs?['default'] as Map<String, dynamic>?;
    return (medium?['url'] ?? high?['url'] ?? def?['url'] ?? '').toString();
  }

  Uri _uri(String path, Map<String, String> params) {
    final root = baseUrl.endsWith('/')
        ? baseUrl.substring(0, baseUrl.length - 1)
        : baseUrl;
    return Uri.parse('$root$path').replace(queryParameters: params);
  }

  Future<Map<String, dynamic>> _getJson(Uri uri) async {
    http.Response resp;
    try {
      resp = await _client.get(uri).timeout(const Duration(seconds: 20));
    } catch (e) {
      throw ApiException('Network error: $e');
    }
    if (resp.statusCode != 200) {
      throw ApiException('HTTP ${resp.statusCode} for ${uri.path}');
    }
    try {
      return jsonDecode(resp.body) as Map<String, dynamic>;
    } catch (e) {
      throw ApiException('Parse error: $e');
    }
  }

  void dispose() => _client.close();
}
