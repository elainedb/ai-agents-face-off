import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/services.dart' show rootBundle;
import '../models/video.dart';

class ApiService {
  final String apiBaseUrl;
  final String apiKey;

  ApiService({
    required this.apiBaseUrl,
    required this.apiKey,
  });

  // Load configured channels
  Future<List<Map<String, String>>> loadChannels() async {
    try {
      final String jsonStr = await rootBundle.loadString('config/channels.json');
      final List<dynamic> decoded = jsonDecode(jsonStr) as List<dynamic>;
      return decoded.map((item) => {
        'id': item['id'] as String,
        'label': item['label'] as String,
      }).toList();
    } catch (e) {
      print('Error loading channels from asset: $e');
    }
    // Fallback static configuration if asset fails
    return [
      {"id": "UCynoa1DjwnvHAowA_jiMEAQ", "label": "cronicas"},
      {"id": "UCK0KOjX3beyB9nzonls0cuw", "label": "bike"},
      {"id": "UCACkIrvrGAQ7kuc0hMVwvmA", "label": "mnt"},
      {"id": "UCtWRAKKvOEA0CXOue9BG8ZA", "label": "mct"}
    ];
  }

  // Fetch all videos from all channels
  Future<List<Video>> fetchAllVideos() async {
    final channels = await loadChannels();
    final Map<String, String> videoIdToCategory = {};
    final List<String> allVideoIds = [];

    String baseUrl = apiBaseUrl;
    if (!baseUrl.startsWith('http://') && !baseUrl.startsWith('https://')) {
      baseUrl = 'https://$baseUrl';
    }
    if (baseUrl.endsWith('/')) {
      baseUrl = baseUrl.substring(0, baseUrl.length - 1);
    }

    // 1. Fetch search.list for each channel
    for (final channel in channels) {
      final channelId = channel['id']!;
      final categoryLabel = channel['label']!;
      
      String? nextPageToken;
      bool hasNextPage = true;

      while (hasNextPage) {
        final queryParams = {
          'key': apiKey,
          'channelId': channelId,
          'part': 'snippet',
          'order': 'date',
          'type': 'video',
          'maxResults': '50',
        };
        if (nextPageToken != null) {
          queryParams['pageToken'] = nextPageToken;
        }

        final uri = Uri.parse('$baseUrl/youtube/v3/search').replace(queryParameters: queryParams);
        print('Fetching search for channel $categoryLabel: $uri');
        final response = await http.get(uri);

        if (response.statusCode != 200) {
          throw Exception('Failed to fetch search results for channel $categoryLabel: ${response.statusCode} - ${response.body}');
        }

        final data = jsonDecode(response.body) as Map<String, dynamic>;
        final items = data['items'] as List<dynamic>? ?? [];
        for (final item in items) {
          final idObj = item['id'] as Map<String, dynamic>?;
          if (idObj != null && idObj['kind'] == 'youtube#video') {
            final videoId = idObj['videoId'] as String?;
            if (videoId != null) {
              videoIdToCategory[videoId] = categoryLabel;
              if (!allVideoIds.contains(videoId)) {
                allVideoIds.add(videoId);
              }
            }
          }
        }

        nextPageToken = data['nextPageToken'] as String?;
        hasNextPage = nextPageToken != null && nextPageToken.isNotEmpty;
      }
    }

    if (allVideoIds.isEmpty) {
      return [];
    }

    // 2. Fetch videos.list details in batches of 50
    final List<Video> aggregatedVideos = [];
    final int batchSize = 50;
    for (int i = 0; i < allVideoIds.length; i += batchSize) {
      final batchIds = allVideoIds.sublist(i, i + batchSize > allVideoIds.length ? allVideoIds.length : i + batchSize);
      final commaJoinedIds = batchIds.join(',');

      final queryParams = {
        'key': apiKey,
        'id': commaJoinedIds,
        'part': 'snippet,contentDetails,recordingDetails',
      };

      final uri = Uri.parse('$baseUrl/youtube/v3/videos').replace(queryParameters: queryParams);
      print('Fetching details for batch: $uri');
      final response = await http.get(uri);

      if (response.statusCode != 200) {
        throw Exception('Failed to fetch video details: ${response.statusCode} - ${response.body}');
      }

      final data = jsonDecode(response.body) as Map<String, dynamic>;
      final items = data['items'] as List<dynamic>? ?? [];

      for (final item in items) {
        final id = item['id'] as String;
        final snippet = item['snippet'] as Map<String, dynamic>? ?? {};
        final recordingDetails = item['recordingDetails'] as Map<String, dynamic>?;

        final title = snippet['title'] as String? ?? 'No Title';
        final description = snippet['description'] as String? ?? '';
        final publishedAtStr = snippet['publishedAt'] as String? ?? DateTime.now().toIso8601String();
        final publishedAt = DateTime.parse(publishedAtStr);

        final thumbnails = snippet['thumbnails'] as Map<String, dynamic>? ?? {};
        final mediumThumb = thumbnails['medium'] as Map<String, dynamic>?;
        final highThumb = thumbnails['high'] as Map<String, dynamic>?;
        final defaultThumb = thumbnails['default'] as Map<String, dynamic>?;
        final thumbnailUrl = (mediumThumb?['url'] ?? highThumb?['url'] ?? defaultThumb?['url'] ?? '') as String;

        double? lat;
        double? lng;
        if (recordingDetails != null) {
          final location = recordingDetails['location'] as Map<String, dynamic>?;
          if (location != null) {
            lat = (location['latitude'] as num?)?.toDouble();
            lng = (location['longitude'] as num?)?.toDouble();
          }
        }

        final category = videoIdToCategory[id] ?? 'unknown';

        aggregatedVideos.add(Video(
          id: id,
          title: title,
          description: description,
          publishedAt: publishedAt,
          category: category,
          lat: lat,
          lng: lng,
          thumbnailUrl: thumbnailUrl,
          youtubeUrl: 'https://www.youtube.com/watch?v=$id',
        ));
      }
    }

    return aggregatedVideos;
  }
}
