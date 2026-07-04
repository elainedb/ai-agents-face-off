import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:injectable/injectable.dart';
import '../../core/config/test_config.dart';
import '../../core/error/failure.dart';
import '../../domain/entities/channel.dart';
import '../../domain/entities/video.dart';

abstract class VideoRemoteDataSource {
  Future<List<Video>> getVideos(List<Channel> channels);
}

@LazySingleton(as: VideoRemoteDataSource)
class VideoRemoteDataSourceImpl implements VideoRemoteDataSource {
  final http.Client client;

  VideoRemoteDataSourceImpl(this.client);

  String get _baseUrl {
    final url = TestConfig.instance.apiBaseUrl;
    if (url != null && url.isNotEmpty) {
      return url;
    }
    return 'https://www.googleapis.com';
  }

  String get _apiKey {
    final key = TestConfig.instance.apiKey;
    if (key != null && key.isNotEmpty) return key;
    return 'dummy-api-key';
  }

  @override
  Future<List<Video>> getVideos(List<Channel> channels) async {
    final List<Video> allVideos = [];

    for (final channel in channels) {
      String? pageToken;
      do {
        final queryParams = {
          'key': _apiKey,
          'channelId': channel.id,
          'part': 'snippet',
          'order': 'date',
          'type': 'video',
          'maxResults': '50',
          if (pageToken != null) 'pageToken': pageToken,
        };

        final uri = Uri.parse('$_baseUrl/youtube/v3/search').replace(queryParameters: queryParams);
        
        final response = await client.get(uri);
        
        if (response.statusCode != 200) {
          throw ServerFailure('Failed to fetch videos for channel ${channel.id}');
        }

        final data = json.decode(response.body);
        final items = data['items'] as List<dynamic>? ?? [];

        if (items.isEmpty) break;

        final List<String> videoIds = [];
        final Map<String, dynamic> videoSnippets = {};

        for (final item in items) {
          final idObj = item['id'];
          if (idObj is Map && idObj['videoId'] != null) {
            final videoId = idObj['videoId'] as String;
            videoIds.add(videoId);
            videoSnippets[videoId] = item['snippet'];
          }
        }

        if (videoIds.isNotEmpty) {
          // Fetch details to get location
          final detailsUri = Uri.parse('$_baseUrl/youtube/v3/videos').replace(queryParameters: {
            'key': _apiKey,
            'id': videoIds.join(','),
            'part': 'snippet,contentDetails,recordingDetails',
          });

          final detailsResponse = await client.get(detailsUri);
          if (detailsResponse.statusCode == 200) {
            final detailsData = json.decode(detailsResponse.body);
            final detailItems = detailsData['items'] as List<dynamic>? ?? [];

            for (final detail in detailItems) {
              final id = detail['id'] as String;
              final snippet = detail['snippet'] ?? videoSnippets[id];
              final recordingDetails = detail['recordingDetails'];
              final contentDetails = detail['contentDetails'];
              
              double? lat;
              double? lng;
              if (recordingDetails != null && recordingDetails['location'] != null) {
                lat = (recordingDetails['location']['latitude'] as num?)?.toDouble();
                lng = (recordingDetails['location']['longitude'] as num?)?.toDouble();
              }

              String durationStr = '';
              if (contentDetails != null && contentDetails['duration'] != null) {
                durationStr = contentDetails['duration'] as String;
              }

              allVideos.add(
                Video(
                  id: id,
                  title: snippet['title'] ?? '',
                  description: snippet['description'] ?? '',
                  publishedAt: DateTime.parse(snippet['publishedAt']),
                  category: channel.label,
                  thumbnailUrl: snippet['thumbnails']?['medium']?['url'] ?? '',
                  duration: durationStr,
                  lat: lat,
                  lng: lng,
                )
              );
            }
          }
        }

        pageToken = data['nextPageToken'] as String?;
      } while (pageToken != null);
    }

    // Deduplicate by ID
    final deduplicated = <String, Video>{};
    for (var video in allVideos) {
      deduplicated[video.id] = video;
    }

    return deduplicated.values.toList();
  }
}
