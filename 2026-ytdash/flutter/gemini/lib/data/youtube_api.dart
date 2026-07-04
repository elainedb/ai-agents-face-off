import 'dart:convert';
import 'package:http/http.dart' as http;
import '../domain/models.dart';
import '../test_config.dart';

class YouTubeApi {
  final http.Client _client = http.Client();

  String get _baseUrl {
    final override = TestConfig.instance.apiBaseUrl;
    if (override != null && override.isNotEmpty) {
      if (override.contains('127.0.0.1') || override.contains('localhost')) {
        return override.replaceAll('127.0.0.1', '10.0.2.2').replaceAll('localhost', '10.0.2.2');
      }
      return override;
    }
    return 'https://www.googleapis.com';
  }

  String get _apiKey {
    final override = TestConfig.instance.apiKey;
    if (override != null && override.isNotEmpty) {
      return override;
    }
    // We don't hardcode production key here for security, though the prompt says "read it at RUNTIME from the extras".
    return const String.fromEnvironment('YOUTUBE_API_KEY', defaultValue: '');
  }

  Future<List<Video>> fetchAllVideos(List<ChannelConfig> channels) async {
    final allVideos = <Video>[];

    for (final channel in channels) {
      final channelVideos = await _fetchVideosForChannel(channel);
      allVideos.addAll(channelVideos);
    }

    // Deduplicate by id
    final seen = <String>{};
    final uniqueVideos = <Video>[];
    for (final v in allVideos) {
      if (!seen.contains(v.id)) {
        seen.add(v.id);
        uniqueVideos.add(v);
      }
    }

    return uniqueVideos;
  }

  Future<List<Video>> _fetchVideosForChannel(ChannelConfig channel) async {
    final videoIds = <String>[];
    String? pageToken;

    // 1. search.list
    do {
      var url = '$_baseUrl/youtube/v3/search?key=$_apiKey&channelId=${channel.id}&part=snippet&order=date&type=video&maxResults=50';
      if (pageToken != null && pageToken.isNotEmpty) {
        url += '&pageToken=$pageToken';
      }

      final uri = Uri.parse(url);
      final response = await _client.get(uri);
      if (response.statusCode != 200) {
        throw Exception('Failed to load search list: ${response.statusCode}');
      }

      final data = json.decode(response.body);
      final items = data['items'] as List<dynamic>? ?? [];

      for (final item in items) {
        final idObj = item['id'];
        if (idObj != null && idObj['videoId'] != null) {
          videoIds.add(idObj['videoId'] as String);
        }
      }

      pageToken = data['nextPageToken'] as String?;
    } while (pageToken != null && pageToken.isNotEmpty);

    // 2. videos.list in chunks of 50
    final videos = <Video>[];
    for (var i = 0; i < videoIds.length; i += 50) {
      final chunk = videoIds.sublist(i, i + 50 > videoIds.length ? videoIds.length : i + 50);
      final chunkIds = chunk.join(',');
      final url = '$_baseUrl/youtube/v3/videos?key=$_apiKey&id=$chunkIds&part=snippet,contentDetails,recordingDetails';
      final uri = Uri.parse(url);
      
      final response = await _client.get(uri);
      if (response.statusCode != 200) {
        throw Exception('Failed to load videos list: ${response.statusCode}');
      }

      final data = json.decode(response.body);
      final items = data['items'] as List<dynamic>? ?? [];

      for (final item in items) {
        final snippet = item['snippet'];
        final recordingDetails = item['recordingDetails'];
        
        Location? location;
        if (recordingDetails != null && recordingDetails['location'] != null) {
          final loc = recordingDetails['location'];
          if (loc['latitude'] != null && loc['longitude'] != null) {
            location = Location(
              lat: (loc['latitude'] as num).toDouble(),
              lng: (loc['longitude'] as num).toDouble(),
            );
          }
        }

        videos.add(Video(
          id: item['id'] as String,
          title: snippet['title'] as String,
          description: snippet['description'] as String? ?? '',
          publishedAt: DateTime.parse(snippet['publishedAt'] as String),
          category: channel.label, // use channel label as category
          thumbnailUrl: snippet['thumbnails']?['medium']?['url'] as String? ?? '',
          location: location,
        ));
      }
    }

    return videos;
  }
}
