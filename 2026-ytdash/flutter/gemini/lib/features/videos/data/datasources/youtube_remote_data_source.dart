import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../../core/config/env_config.dart';
import '../../domain/models/video.dart';
import '../../../../test_config.dart';
import '../../../../core/error/failures.dart';

class YoutubeRemoteDataSource {
  final http.Client client;

  YoutubeRemoteDataSource({required this.client});

  Future<List<Video>> fetchAllVideos() async {
    final baseUrl =
        TestConfig.instance.apiBaseUrl ?? 'https://www.googleapis.com';
    final apiKey = TestConfig.instance.apiKey ?? AppConfig.youtubeApiKey;

    List<Video> allVideos = [];

    for (final channel in AppConfig.channels) {
      final channelId = channel['id']!;
      final category = channel['label']!;
      String? pageToken = '';

      final Map<String, dynamic> snippetMap = {};

      while (pageToken != null) {
        final uri = Uri.parse(
          '$baseUrl/youtube/v3/search?key=$apiKey&channelId=$channelId&part=snippet&order=date&type=video&maxResults=50${pageToken.isNotEmpty ? '&pageToken=$pageToken' : ''}',
        );
        final response = await client.get(uri);

        if (response.statusCode != 200) {
          throw ServerFailure(
            'Failed to fetch search.list: ${response.statusCode}',
          );
        }

        final data = json.decode(response.body);
        final items = data['items'] as List<dynamic>? ?? [];

        for (final item in items) {
          final videoId = item['id']['videoId'];
          snippetMap[videoId] = item['snippet'];
        }

        pageToken = data['nextPageToken'] as String?;
      }

      // Now fetch details using videos.list in chunks of 50
      final videoIds = snippetMap.keys.toList();
      for (var i = 0; i < videoIds.length; i += 50) {
        final chunk = videoIds.sublist(
          i,
          i + 50 > videoIds.length ? videoIds.length : i + 50,
        );
        final idsStr = chunk.join(',');

        final uri = Uri.parse(
          '$baseUrl/youtube/v3/videos?key=$apiKey&id=$idsStr&part=snippet,contentDetails,recordingDetails',
        );
        final response = await client.get(uri);

        if (response.statusCode != 200) {
          throw ServerFailure(
            'Failed to fetch videos.list: ${response.statusCode}',
          );
        }

        final data = json.decode(response.body);
        final items = data['items'] as List<dynamic>? ?? [];

        for (final item in items) {
          final id = item['id'] as String;
          final snippet = item['snippet'];
          final recordingDetails = item['recordingDetails'];

          double? lat;
          double? lng;
          if (recordingDetails != null &&
              recordingDetails['location'] != null) {
            lat = (recordingDetails['location']['latitude'] as num?)
                ?.toDouble();
            lng = (recordingDetails['location']['longitude'] as num?)
                ?.toDouble();
          }

          String thumbnailUrl = '';
          if (snippet['thumbnails'] != null) {
            if (snippet['thumbnails']['medium'] != null) {
              thumbnailUrl = snippet['thumbnails']['medium']['url'];
            } else if (snippet['thumbnails']['default'] != null) {
              thumbnailUrl = snippet['thumbnails']['default']['url'];
            }
          }

          allVideos.add(
            Video(
              id: id,
              title: snippet['title'] ?? '',
              description: snippet['description'] ?? '',
              publishedAt: DateTime.parse(snippet['publishedAt']),
              category: category,
              thumbnailUrl: thumbnailUrl,
              lat: lat,
              lng: lng,
            ),
          );
        }
      }
    }

    // Deduplicate by ID
    final uniqueVideos = <String, Video>{};
    for (final v in allVideos) {
      if (!uniqueVideos.containsKey(v.id)) {
        uniqueVideos[v.id] = v;
      }
    }
    return uniqueVideos.values.toList();
  }
}
