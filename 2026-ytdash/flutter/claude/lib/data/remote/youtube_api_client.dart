import 'dart:convert';

import 'package:http/http.dart' as http;

import 'youtube_dtos.dart';

class ChannelConfig {
  const ChannelConfig({required this.id, required this.label});
  final String id;
  final String label;
}

class YoutubeApiException implements Exception {
  YoutubeApiException(this.message);
  final String message;
  @override
  String toString() => 'YoutubeApiException: $message';
}

/// Talks to the YouTube-Data-API-v3-shaped endpoints (mock or real; only `baseUrl`/`apiKey`
/// differ) — see `spec/youtube-api.md`. There is NO catch-all query: callers must iterate the
/// configured channels themselves and merge/dedupe (constitution + spec §Data).
class YoutubeApiClient {
  YoutubeApiClient({
    required this.baseUrl,
    required this.apiKey,
    http.Client? httpClient,
  }) : _client = httpClient ?? http.Client();

  final String baseUrl;
  final String apiKey;
  final http.Client _client;

  Uri _uri(String endpoint, Map<String, String> query) {
    final root = baseUrl.endsWith('/')
        ? baseUrl.substring(0, baseUrl.length - 1)
        : baseUrl;
    return Uri.parse(
      '$root/youtube/v3/$endpoint',
    ).replace(queryParameters: {...query, 'key': apiKey});
  }

  /// Fetches every video for [channel] via `search.list`, following `nextPageToken` until the
  /// mock/real API stops returning one. A build that reads only page 1 will under-count
  /// (constitution/spec's `AC-COUNT-01` anti-overfit control).
  Future<List<SearchItemDto>> fetchAllForChannel(ChannelConfig channel) async {
    final items = <SearchItemDto>[];
    String? pageToken;
    do {
      final uri = _uri('search', {
        'part': 'snippet',
        'channelId': channel.id,
        'type': 'video',
        'order': 'date',
        'maxResults': '50',
        if (pageToken != null && pageToken.isNotEmpty) 'pageToken': pageToken,
      });
      final response = await _client.get(uri);
      if (response.statusCode != 200) {
        throw YoutubeApiException(
          'search.list failed for channel ${channel.id}: HTTP ${response.statusCode}',
        );
      }
      final json = jsonDecode(response.body) as Map<String, dynamic>;
      for (final raw in (json['items'] as List<dynamic>? ?? const [])) {
        items.add(
          SearchItemDto.fromSearchJson(
            raw as Map<String, dynamic>,
            channel.label,
          ),
        );
      }
      pageToken = json['nextPageToken'] as String?;
    } while (pageToken != null && pageToken.isNotEmpty);
    return items;
  }

  /// Batches `videos.list` calls (max 50 ids/call per the real API's limit) to fetch
  /// `recordingDetails.location` for every id.
  Future<Map<String, VideoDetailsDto>> fetchDetails(List<String> ids) async {
    final out = <String, VideoDetailsDto>{};
    const batchSize = 50;
    for (var i = 0; i < ids.length; i += batchSize) {
      final end = (i + batchSize < ids.length) ? i + batchSize : ids.length;
      final batch = ids.sublist(i, end);
      if (batch.isEmpty) continue;
      final uri = _uri('videos', {
        'part': 'snippet,contentDetails,recordingDetails',
        'id': batch.join(','),
      });
      final response = await _client.get(uri);
      if (response.statusCode != 200) {
        throw YoutubeApiException(
          'videos.list failed: HTTP ${response.statusCode}',
        );
      }
      final json = jsonDecode(response.body) as Map<String, dynamic>;
      for (final raw in (json['items'] as List<dynamic>? ?? const [])) {
        final dto = VideoDetailsDto.fromJson(raw as Map<String, dynamic>);
        out[dto.id] = dto;
      }
    }
    return out;
  }
}
