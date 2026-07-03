import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:ytdash_flutter/data/models/video.dart';

class YoutubeService {
  /// Fetches all videos for a channel by paginating through search results,
  /// then fetches their recording details (locations) and maps them to [Video] models.
  Future<List<Video>> fetchVideosForChannel({
    required String channelId,
    required String baseUrl,
    required String apiKey,
    required String categoryLabel,
  }) async {
    final List<Map<String, dynamic>> searchItems = [];
    String? pageToken;

    // Remove trailing slash if any on baseUrl
    final cleanBaseUrl = baseUrl.endsWith('/')
        ? baseUrl.substring(0, baseUrl.length - 1)
        : baseUrl;

    // 1. Paginate through all search results
    do {
      var urlStr = '$cleanBaseUrl/youtube/v3/search'
          '?key=$apiKey'
          '&channelId=$channelId'
          '&part=snippet'
          '&order=date'
          '&type=video'
          '&maxResults=50';

      if (pageToken != null && pageToken.isNotEmpty) {
        urlStr += '&pageToken=$pageToken';
      }

      print('Fetching search page: $urlStr');
      final response = await http.get(Uri.parse(urlStr)).timeout(const Duration(seconds: 10));

      if (response.statusCode != 200) {
        throw Exception(
            'Failed to search videos for channel $channelId. Status: ${response.statusCode}, Body: ${response.body}');
      }

      final Map<String, dynamic> data = jsonDecode(response.body) as Map<String, dynamic>;
      final List<dynamic>? items = data['items'] as List<dynamic>?;
      if (items != null) {
        for (final item in items) {
          if (item is Map<String, dynamic>) {
            searchItems.add(item);
          }
        }
      }

      pageToken = data['nextPageToken'] as String?;
    } while (pageToken != null && pageToken.isNotEmpty);

    if (searchItems.isEmpty) {
      return [];
    }

    // Extract video IDs
    final List<String> videoIds = searchItems.map((item) {
      final idMap = item['id'] as Map<String, dynamic>?;
      return idMap?['videoId'] as String? ?? '';
    }).where((id) => id.isNotEmpty).toList();

    if (videoIds.isEmpty) {
      return [];
    }

    // 2. Fetch details including recordingDetails/location from /videos in chunks of up to 50
    final Map<String, Map<String, double>> videoLocations = {};

    for (int i = 0; i < videoIds.length; i += 50) {
      final chunk = videoIds.sublist(
          i, i + 50 > videoIds.length ? videoIds.length : i + 50);
      final idParam = chunk.join(',');

      final detailsUrl = '$cleanBaseUrl/youtube/v3/videos'
          '?key=$apiKey'
          '&id=$idParam'
          '&part=snippet,contentDetails,recordingDetails';

      print('Fetching video details chunk: $detailsUrl');
      final detailsResponse =
          await http.get(Uri.parse(detailsUrl)).timeout(const Duration(seconds: 10));

      if (detailsResponse.statusCode != 200) {
        throw Exception(
            'Failed to fetch video details. Status: ${detailsResponse.statusCode}');
      }

      final Map<String, dynamic> detailsData =
          jsonDecode(detailsResponse.body) as Map<String, dynamic>;
      final List<dynamic>? detailsItems = detailsData['items'] as List<dynamic>?;

      if (detailsItems != null) {
        for (final item in detailsItems) {
          if (item is Map<String, dynamic>) {
            final id = item['id'] as String? ?? '';
            final recordingDetails =
                item['recordingDetails'] as Map<String, dynamic>?;
            if (recordingDetails != null) {
              final location = recordingDetails['location'] as Map<String, dynamic>?;
              if (location != null) {
                final lat = (location['latitude'] as num?)?.toDouble();
                final lng = (location['longitude'] as num?)?.toDouble();
                if (lat != null && lng != null) {
                  videoLocations[id] = {'lat': lat, 'lng': lng};
                }
              }
            }
          }
        }
      }
    }

    // 3. Construct domain Video objects
    final List<Video> videos = [];
    for (final item in searchItems) {
      final idMap = item['id'] as Map<String, dynamic>?;
      final videoId = idMap?['videoId'] as String? ?? '';
      if (videoId.isEmpty) continue;

      final snippet = item['snippet'] as Map<String, dynamic>? ?? {};
      final title = snippet['title'] as String? ?? '';
      final description = snippet['description'] as String? ?? '';
      final publishedAt = snippet['publishedAt'] as String? ?? '';
      final thumbnails = snippet['thumbnails'] as Map<String, dynamic>? ?? {};
      final mediumThumb = thumbnails['medium'] as Map<String, dynamic>? ?? {};
      final defaultThumb = thumbnails['default'] as Map<String, dynamic>? ?? {};
      final thumbnailUrl = mediumThumb['url'] as String? ?? defaultThumb['url'] as String? ?? '';

      final loc = videoLocations[videoId];

      videos.add(Video(
        id: videoId,
        title: title,
        description: description,
        publishedAt: publishedAt,
        category: categoryLabel,
        thumbnailUrl: thumbnailUrl,
        lat: loc?['lat'],
        lng: loc?['lng'],
      ));
    }

    return videos;
  }
}
