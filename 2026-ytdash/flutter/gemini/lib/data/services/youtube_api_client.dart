import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import '../../domain/models/video.dart';
import '../models/test_config.dart';

class YoutubeApiClient {
  final http.Client _client;

  YoutubeApiClient({http.Client? client}) : _client = client ?? http.Client();

  // Load configured channels from assets config/channels.json
  Future<List<Map<String, String>>> loadChannels() async {
    try {
      final content = await rootBundle.loadString('config/channels.json');
      final List<dynamic> jsonList = jsonDecode(content) as List<dynamic>;
      return jsonList.map((item) {
        return {
          'id': item['id'] as String? ?? '',
          'label': item['label'] as String? ?? '',
        };
      }).toList();
    } catch (_) {
      return [];
    }
  }

  // Aggregate and fetch all videos from all channels
  Future<List<Video>> fetchAllVideos(TestConfig testConfig, String defaultApiKey) async {
    final baseUrl = testConfig.getResolvedBaseUrl();
    final apiKey = testConfig.getResolvedApiKey(defaultApiKey);

    final channels = await loadChannels();
    if (channels.isEmpty) return [];

    // Map to hold aggregated and deduplicated video structures
    // Key: videoId, Value: Video object
    final Map<String, Video> videoMap = {};

    for (final channel in channels) {
      final channelId = channel['id'];
      final categoryLabel = channel['label'];
      if (channelId == null || channelId.isEmpty || categoryLabel == null) continue;

      String? nextPageToken;
      do {
        final queryParams = {
          'key': apiKey,
          'channelId': channelId,
          'part': 'snippet',
          'order': 'date',
          'type': 'video',
          'maxResults': '50',
          if (nextPageToken != null) 'pageToken': nextPageToken,
        };

        final uri = Uri.parse('$baseUrl/youtube/v3/search').replace(queryParameters: queryParams);
        final response = await _client.get(uri);

        if (response.statusCode != 200) {
          throw Exception('Failed to fetch search results for channel $channelId: ${response.statusCode}');
        }

        final Map<String, dynamic> data = jsonDecode(response.body) as Map<String, dynamic>;
        final List<dynamic> items = data['items'] as List<dynamic>? ?? [];

        for (final item in items) {
          final idObj = item['id'];
          if (idObj == null) continue;
          final videoId = idObj['videoId'] as String?;
          if (videoId == null || videoId.isEmpty) continue;

          final snippet = item['snippet'];
          if (snippet == null) continue;

          final title = snippet['title'] as String? ?? '';
          final description = snippet['description'] as String? ?? '';
          final publishedAt = snippet['publishedAt'] as String? ?? '';
          final thumbnailUrl = _getThumbnailUrl(snippet as Map<String, dynamic>);

          // Deduplicate across channels but ensure category is set
          videoMap[videoId] = Video(
            id: videoId,
            title: title,
            description: description,
            publishedAt: publishedAt,
            category: categoryLabel,
            thumbnailUrl: thumbnailUrl,
          );
        }

        nextPageToken = data['nextPageToken'] as String?;
      } while (nextPageToken != null && nextPageToken.isNotEmpty);
    }

    final videoIds = videoMap.keys.toList();
    if (videoIds.isEmpty) return [];

    // Fetch video details + locations in batches of up to 50
    final enrichedVideos = <Video>[];
    for (var i = 0; i < videoIds.length; i += 50) {
      final end = (i + 50 < videoIds.length) ? i + 50 : videoIds.length;
      final batchIds = videoIds.sublist(i, end);
      final batchDetails = await _fetchVideoDetailsBatch(baseUrl, apiKey, batchIds);

      for (final id in batchIds) {
        final originalVideo = videoMap[id]!;
        final details = batchDetails[id];
        if (details != null) {
          enrichedVideos.add(originalVideo.copyWith(
            latitude: details['latitude'],
            longitude: details['longitude'],
            // Enriched details might have updated title or thumbnail
            title: details['title'] ?? originalVideo.title,
            description: details['description'] ?? originalVideo.description,
          ));
        } else {
          enrichedVideos.add(originalVideo);
        }
      }
    }

    return enrichedVideos;
  }

  // Fetch detailed info (e.g. location) for a batch of up to 50 video IDs
  Future<Map<String, Map<String, dynamic>>> _fetchVideoDetailsBatch(
    String baseUrl,
    String apiKey,
    List<String> videoIds,
  ) async {
    final idParam = videoIds.join(',');
    final uri = Uri.parse('$baseUrl/youtube/v3/videos').replace(queryParameters: {
      'key': apiKey,
      'id': idParam,
      'part': 'snippet,contentDetails,recordingDetails',
    });

    final response = await _client.get(uri);
    if (response.statusCode != 200) {
      throw Exception('Failed to fetch video details: ${response.statusCode}');
    }

    final Map<String, dynamic> data = jsonDecode(response.body) as Map<String, dynamic>;
    final List<dynamic> items = data['items'] as List<dynamic>? ?? [];

    final Map<String, Map<String, dynamic>> detailsMap = {};
    for (final item in items) {
      final id = item['id'] as String?;
      if (id == null) continue;

      double? latitude;
      double? longitude;
      final recordingDetails = item['recordingDetails'];
      if (recordingDetails != null) {
        final location = recordingDetails['location'];
        if (location != null) {
          latitude = (location['latitude'] as num?)?.toDouble();
          longitude = (location['longitude'] as num?)?.toDouble();
        }
      }

      final snippet = item['snippet'];
      final title = snippet?['title'] as String?;
      final description = snippet?['description'] as String?;

      detailsMap[id] = {
        'latitude': latitude,
        'longitude': longitude,
        'title': title,
        'description': description,
      };
    }

    return detailsMap;
  }

  String _getThumbnailUrl(Map<String, dynamic> snippet) {
    final thumbnails = snippet['thumbnails'];
    if (thumbnails != null) {
      if (thumbnails['medium'] != null) {
        return thumbnails['medium']['url'] as String? ?? '';
      }
      if (thumbnails['default'] != null) {
        return thumbnails['default']['url'] as String? ?? '';
      }
      if (thumbnails['high'] != null) {
        return thumbnails['high']['url'] as String? ?? '';
      }
    }
    return '';
  }
}
