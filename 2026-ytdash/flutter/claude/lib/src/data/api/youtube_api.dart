import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../config/app_config.dart';
import '../models/video.dart';

/// Thrown for any network/parse failure so the repository can apply the
/// stale-cache fallback and the UI can surface a retryable error.
class ApiException implements Exception {
  ApiException(this.message);
  final String message;
  @override
  String toString() => 'ApiException: $message';
}

/// Talks to the YouTube Data API v3 shapes (mock OR real — same code, swapped
/// base URL + key at runtime, constitution §4). Mirrors spec/youtube-api.md.
class YoutubeApi {
  YoutubeApi({
    required this.baseUrl,
    this.apiKey,
    http.Client? client,
  }) : _client = client ?? http.Client();

  /// Host root, e.g. `http://127.0.0.1:8090` or `https://www.googleapis.com`.
  /// We append `/youtube/v3/<endpoint>` ourselves.
  final String baseUrl;
  final String? apiKey;
  final http.Client _client;

  /// Aggregate every configured channel, following pagination, and enrich with
  /// recording locations. Returns videos in channel+API order, deduped by id.
  Future<List<Video>> fetchAllVideos(List<SourceChannel> channels) async {
    final byId = <String, Video>{};
    final order = <String>[];

    for (final channel in channels) {
      final channelVideos = await _searchChannel(channel);
      for (final v in channelVideos) {
        if (!byId.containsKey(v.id)) {
          order.add(v.id);
        }
        // First channel that yields an id wins its label (deterministic order).
        byId.putIfAbsent(v.id, () => v);
      }
    }

    if (byId.isEmpty) return [];

    // Enrich with locations via videos.list (batched ≤50).
    final locations = await _fetchLocations(order);
    for (final entry in locations.entries) {
      final base = byId[entry.key];
      if (base != null) {
        byId[entry.key] = base.copyWith(lat: entry.value.$1, lng: entry.value.$2);
      }
    }

    return [for (final id in order) byId[id]!];
  }

  /// `search.list` for one channel, following `nextPageToken` to exhaustion.
  Future<List<Video>> _searchChannel(SourceChannel channel) async {
    final out = <Video>[];
    String? pageToken;
    do {
      final uri = _uri('/youtube/v3/search', {
        'channelId': channel.id,
        'part': 'snippet',
        'order': 'date',
        'type': 'video',
        'maxResults': '50',
        'pageToken': ?pageToken,
      });
      final json = await _getJson(uri);
      final items = (json['items'] as List?) ?? const [];
      for (final item in items) {
        final v = Video.fromSearchItem(
          item as Map<String, dynamic>,
          category: channel.label,
        );
        if (v != null) out.add(v);
      }
      pageToken = json['nextPageToken'] as String?;
    } while (pageToken != null && pageToken.isNotEmpty);
    return out;
  }

  /// `videos.list` batched, returning id -> (lat,lng) for located videos only.
  Future<Map<String, (double, double)>> _fetchLocations(List<String> ids) async {
    final result = <String, (double, double)>{};
    for (var i = 0; i < ids.length; i += 50) {
      final batch = ids.sublist(i, i + 50 > ids.length ? ids.length : i + 50);
      final uri = _uri('/youtube/v3/videos', {
        'id': batch.join(','),
        'part': 'snippet,contentDetails,recordingDetails',
      });
      final json = await _getJson(uri);
      final items = (json['items'] as List?) ?? const [];
      for (final item in items) {
        final m = item as Map<String, dynamic>;
        final id = m['id'] as String?;
        final loc = (m['recordingDetails'] as Map?)?['location'] as Map?;
        if (id != null && loc != null) {
          final lat = (loc['latitude'] as num?)?.toDouble();
          final lng = (loc['longitude'] as num?)?.toDouble();
          if (lat != null && lng != null) result[id] = (lat, lng);
        }
      }
    }
    return result;
  }

  Uri _uri(String path, Map<String, String> params) {
    final base = Uri.parse(baseUrl);
    final merged = {
      ...params,
      if (apiKey != null && apiKey!.isNotEmpty) 'key': apiKey!,
    };
    return base.replace(path: path, queryParameters: merged);
  }

  Future<Map<String, dynamic>> _getJson(Uri uri) async {
    final http.Response resp;
    try {
      resp = await _client.get(uri).timeout(const Duration(seconds: 20));
    } catch (e) {
      throw ApiException('network error: $e');
    }
    if (resp.statusCode != 200) {
      throw ApiException('HTTP ${resp.statusCode} for ${uri.path}');
    }
    try {
      return jsonDecode(resp.body) as Map<String, dynamic>;
    } catch (e) {
      throw ApiException('parse error: $e');
    }
  }

  void dispose() => _client.close();
}
