import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../domain/models/source_channel.dart';
import '../../domain/models/video.dart';

/// Talks to the YouTube Data API v3 (or the mock that mirrors its shapes exactly).
///
/// [baseUrl] is the host root only (e.g. `https://www.googleapis.com` or
/// `http://127.0.0.1:8090`) — `/youtube/v3/<endpoint>` is appended here, never baked into the
/// base itself, so the same code works against mock and real (constitution §2, §4).
class YoutubeApiClient {
  YoutubeApiClient({
    required this.baseUrl,
    required this.apiKey,
    http.Client? httpClient,
  }) : _http = httpClient ?? http.Client();

  final String baseUrl;
  final String apiKey;
  final http.Client _http;

  Uri _uri(String endpoint, Map<String, String> query) {
    final root = baseUrl.endsWith('/')
        ? baseUrl.substring(0, baseUrl.length - 1)
        : baseUrl;
    return Uri.parse(
      '$root/youtube/v3/$endpoint',
    ).replace(queryParameters: {'key': apiKey, ...query});
  }

  /// Fetches every video uploaded by [channel], following `nextPageToken` to exhaustion.
  /// There is no catch-all endpoint — callers must call this once per configured channel.
  Future<List<Video>> fetchChannelVideos(SourceChannel channel) async {
    final videos = <Video>[];
    String? pageToken;
    do {
      final uri = _uri('search', {
        'channelId': channel.id,
        'part': 'snippet',
        'order': 'date',
        'type': 'video',
        'maxResults': '50',
        if (pageToken != null) 'pageToken': pageToken,
      });
      final response = await _http.get(uri);
      if (response.statusCode != 200) {
        throw YoutubeApiException(
          'search.list failed for channel ${channel.id}: HTTP ${response.statusCode}',
        );
      }
      final body = jsonDecode(response.body) as Map<String, dynamic>;
      final items = (body['items'] as List<dynamic>? ?? const [])
          .cast<Map<String, dynamic>>();
      for (final item in items) {
        final id = item['id'] as Map<String, dynamic>?;
        final videoId = id?['videoId'] as String?;
        final snippet = item['snippet'] as Map<String, dynamic>?;
        if (videoId == null || snippet == null) continue;
        final thumbnails =
            snippet['thumbnails'] as Map<String, dynamic>? ?? const {};
        final medium = thumbnails['medium'] as Map<String, dynamic>?;
        final publishedRaw = snippet['publishedAt'] as String?;
        videos.add(
          Video(
            id: videoId,
            title: snippet['title'] as String? ?? '',
            description: snippet['description'] as String? ?? '',
            publishedAt: publishedRaw != null
                ? DateTime.parse(publishedRaw)
                : DateTime.fromMillisecondsSinceEpoch(0),
            category: channel.label,
            thumbnailUrl: medium?['url'] as String? ?? '',
          ),
        );
      }
      pageToken = body['nextPageToken'] as String?;
    } while (pageToken != null);
    return videos;
  }

  /// Batched `videos.list` lookup (up to 50 ids per call) for `recordingDetails.location`.
  /// Returns a map of videoId -> (lat, lng) for the subset of ids that have a location.
  Future<Map<String, (double, double)>> fetchLocations(List<String> ids) async {
    final result = <String, (double, double)>{};
    for (var i = 0; i < ids.length; i += 50) {
      final chunk = ids.sublist(i, i + 50 > ids.length ? ids.length : i + 50);
      if (chunk.isEmpty) continue;
      final uri = _uri('videos', {
        'id': chunk.join(','),
        'part': 'snippet,contentDetails,recordingDetails',
      });
      final response = await _http.get(uri);
      if (response.statusCode != 200) {
        throw YoutubeApiException(
          'videos.list failed: HTTP ${response.statusCode}',
        );
      }
      final body = jsonDecode(response.body) as Map<String, dynamic>;
      final items = (body['items'] as List<dynamic>? ?? const [])
          .cast<Map<String, dynamic>>();
      for (final item in items) {
        final id = item['id'] as String?;
        final recording = item['recordingDetails'] as Map<String, dynamic>?;
        final location = recording?['location'] as Map<String, dynamic>?;
        if (id == null || location == null) continue;
        final lat = (location['latitude'] as num?)?.toDouble();
        final lng = (location['longitude'] as num?)?.toDouble();
        if (lat != null && lng != null) {
          result[id] = (lat, lng);
        }
      }
    }
    return result;
  }
}

class YoutubeApiException implements Exception {
  YoutubeApiException(this.message);
  final String message;

  @override
  String toString() => 'YoutubeApiException: $message';
}
