import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/channel.dart';
import '../models/video.dart';

/// Thrown for any network/parse failure talking to the YouTube Data API (mock or real).
class YoutubeApiException implements Exception {
  YoutubeApiException(this.message);
  final String message;

  @override
  String toString() => 'YoutubeApiException: $message';
}

/// Thin client over the YouTube Data API v3 signatures (spec/youtube-api.md). Talks to whichever
/// `baseUrl` it's given (the mock server or `https://www.googleapis.com`) — the shapes are
/// identical, so no branching is needed between mock and real.
class YoutubeApiClient {
  YoutubeApiClient({
    required this.baseUrl,
    required this.apiKey,
    http.Client? httpClient,
  }) : _client = httpClient ?? http.Client();

  final String baseUrl;
  final String apiKey;
  final http.Client _client;

  Uri _uri(String path, Map<String, String> query) {
    final base = Uri.parse(baseUrl);
    return base.replace(
      path: '${base.path}/youtube/v3/$path'.replaceAll('//', '/'),
      queryParameters: {'key': apiKey, ...query},
    );
  }

  Future<Map<String, dynamic>> _getJson(Uri uri) async {
    final http.Response response;
    try {
      response = await _client.get(uri).timeout(const Duration(seconds: 20));
    } catch (e) {
      throw YoutubeApiException('Network error calling $uri: $e');
    }
    if (response.statusCode != 200) {
      throw YoutubeApiException('HTTP ${response.statusCode} calling $uri');
    }
    try {
      return jsonDecode(response.body) as Map<String, dynamic>;
    } catch (e) {
      throw YoutubeApiException('Failed to parse response from $uri: $e');
    }
  }

  /// Fetches every video for a single channel, following `nextPageToken` until exhausted.
  /// This is what makes `video_count` correct — a build that stops at page 1 undercounts.
  Future<List<_SearchItem>> _fetchAllForChannel(SourceChannel channel) async {
    final items = <_SearchItem>[];
    String? pageToken;
    do {
      final json = await _getJson(
        _uri('search', {
          'channelId': channel.id,
          'part': 'snippet',
          'order': 'date',
          'type': 'video',
          'maxResults': '50',
          if (pageToken != null) 'pageToken': pageToken,
        }),
      );
      final rawItems = (json['items'] as List?) ?? const [];
      for (final raw in rawItems) {
        final map = raw as Map<String, dynamic>;
        final videoId =
            (map['id'] as Map<String, dynamic>?)?['videoId'] as String?;
        final snippet = map['snippet'] as Map<String, dynamic>?;
        if (videoId == null || snippet == null) continue;
        items.add(_SearchItem(videoId: videoId, snippet: snippet));
      }
      pageToken = json['nextPageToken'] as String?;
    } while (pageToken != null);
    return items;
  }

  /// Fetches recordingDetails/location for a batch of video ids (up to 50, per the API's comma-join
  /// limit).
  Future<Map<String, Map<String, dynamic>>> _fetchDetails(
    List<String> ids,
  ) async {
    final result = <String, Map<String, dynamic>>{};
    for (var i = 0; i < ids.length; i += 50) {
      final batch = ids.sublist(i, i + 50 > ids.length ? ids.length : i + 50);
      final json = await _getJson(
        _uri('videos', {
          'id': batch.join(','),
          'part': 'snippet,contentDetails,recordingDetails',
        }),
      );
      final rawItems = (json['items'] as List?) ?? const [];
      for (final raw in rawItems) {
        final map = raw as Map<String, dynamic>;
        final id = map['id'] as String?;
        if (id == null) continue;
        result[id] = map;
      }
    }
    return result;
  }

  /// Aggregates every configured channel's videos (paginating each fully), merges/dedupes by
  /// video id, then enriches with location via `videos.list`. No catch-all channel query exists on
  /// the real API, so every channel in [channels] is iterated explicitly.
  Future<List<Video>> fetchAllVideos(List<SourceChannel> channels) async {
    final byId = <String, _SearchItem>{};
    for (final channel in channels) {
      final items = await _fetchAllForChannel(channel);
      for (final item in items) {
        byId.putIfAbsent(item.videoId, () => item);
      }
    }
    if (byId.isEmpty) return const [];

    final details = await _fetchDetails(byId.keys.toList());

    return byId.values.map((item) {
      final snippet = item.snippet;
      final thumbnails = snippet['thumbnails'] as Map<String, dynamic>?;
      final thumbUrl =
          (thumbnails?['medium'] as Map<String, dynamic>?)?['url'] as String? ??
          (thumbnails?['default'] as Map<String, dynamic>?)?['url']
              as String? ??
          '';
      final location =
          (details[item.videoId]?['recordingDetails']
                  as Map<String, dynamic>?)?['location']
              as Map<String, dynamic>?;
      return Video(
        id: item.videoId,
        title: snippet['title'] as String? ?? '',
        description: snippet['description'] as String? ?? '',
        publishedAt:
            DateTime.tryParse(snippet['publishedAt'] as String? ?? '') ??
            DateTime.fromMillisecondsSinceEpoch(0),
        category: snippet['channelTitle'] as String? ?? '',
        thumbnailUrl: thumbUrl,
        lat: (location?['latitude'] as num?)?.toDouble(),
        lng: (location?['longitude'] as num?)?.toDouble(),
      );
    }).toList();
  }

  void close() => _client.close();
}

class _SearchItem {
  _SearchItem({required this.videoId, required this.snippet});
  final String videoId;
  final Map<String, dynamic> snippet;
}
