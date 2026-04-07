import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:injectable/injectable.dart';
import 'package:ytdash_flutter_claude/config/config.dart';
import 'package:ytdash_flutter_claude/core/error/exceptions.dart';
import 'package:ytdash_flutter_claude/features/videos/data/datasources/geocoding_service.dart';
import 'package:ytdash_flutter_claude/features/videos/data/models/video_model.dart';

abstract class VideosRemoteDataSource {
  Future<List<VideoModel>> getVideosFromChannels(List<String> channelIds);
}

@LazySingleton(as: VideosRemoteDataSource)
class VideosRemoteDataSourceImpl implements VideosRemoteDataSource {
  final http.Client client;
  final GeocodingService geocodingService;

  static const _baseUrl = 'https://www.googleapis.com/youtube/v3';

  VideosRemoteDataSourceImpl({
    required this.client,
    required this.geocodingService,
  });

  @override
  Future<List<VideoModel>> getVideosFromChannels(
      List<String> channelIds) async {
    try {
      // Fetch all video IDs from all channels in parallel
      final searchFutures =
          channelIds.map((id) => _searchChannel(id)).toList();
      final searchResults = await Future.wait(searchFutures);
      final allVideoIds = searchResults.expand((ids) => ids).toSet().toList();

      if (allVideoIds.isEmpty) return [];

      // Fetch detailed video info in batches of 50
      final videos = <VideoModel>[];
      for (var i = 0; i < allVideoIds.length; i += 50) {
        final batch = allVideoIds.skip(i).take(50).toList();
        final batchVideos = await _getVideoDetails(batch);
        videos.addAll(batchVideos);
      }

      // Reverse geocode videos with coordinates
      final videosWithCoords = <(int, double, double, String?)>[];
      for (var i = 0; i < videos.length; i++) {
        final v = videos[i];
        if (v.latitude != null && v.longitude != null) {
          videosWithCoords.add((i, v.latitude!, v.longitude!, null));
        }
      }

      if (videosWithCoords.isNotEmpty) {
        final coords = videosWithCoords
            .map((e) => (e.$2, e.$3, e.$4))
            .toList();
        final geocodeResults = await geocodingService.batchGeocode(coords);

        final updatedVideos = List<VideoModel>.from(videos);
        for (var j = 0; j < videosWithCoords.length; j++) {
          final idx = videosWithCoords[j].$1;
          final (city, country) = geocodeResults[j];
          updatedVideos[idx] = updatedVideos[idx].copyWith(
            city: city,
            country: country,
          );
        }
        videos
          ..clear()
          ..addAll(updatedVideos);
      }

      // Sort by publishedAt descending
      videos.sort((a, b) => b.publishedAt.compareTo(a.publishedAt));

      return videos;
    } catch (e) {
      if (e is ServerException) rethrow;
      throw ServerException('Failed to fetch videos: $e');
    }
  }

  Future<List<String>> _searchChannel(String channelId) async {
    final videoIds = <String>[];
    String? pageToken;

    do {
      final queryParams = {
        'part': 'snippet',
        'channelId': channelId,
        'type': 'video',
        'order': 'date',
        'maxResults': '50',
        'key': Config.youtubeApiKey,
        ?pageToken: pageToken,
      };

      final uri = Uri.parse('$_baseUrl/search').replace(
        queryParameters: queryParams,
      );

      final response = await client.get(uri);
      if (response.statusCode != 200) {
        throw ServerException(
            'YouTube search API error: ${response.statusCode} ${response.body}');
      }

      final data = json.decode(response.body) as Map<String, dynamic>;
      final items = data['items'] as List<dynamic>? ?? [];

      for (final item in items) {
        final videoId = item['id']?['videoId'] as String?;
        if (videoId != null) {
          videoIds.add(videoId);
        }
      }

      pageToken = data['nextPageToken'] as String?;
    } while (pageToken != null);

    return videoIds;
  }

  Future<List<VideoModel>> _getVideoDetails(List<String> videoIds) async {
    final uri = Uri.parse('$_baseUrl/videos').replace(
      queryParameters: {
        'part': 'snippet,recordingDetails',
        'id': videoIds.join(','),
        'key': Config.youtubeApiKey,
      },
    );

    final response = await client.get(uri);
    if (response.statusCode != 200) {
      throw ServerException(
          'YouTube videos API error: ${response.statusCode}');
    }

    final data = json.decode(response.body) as Map<String, dynamic>;
    final items = data['items'] as List<dynamic>? ?? [];

    return items.map((item) {
      final snippet = item['snippet'] as Map<String, dynamic>? ?? {};
      final recordingDetails =
          item['recordingDetails'] as Map<String, dynamic>? ?? {};
      final location =
          recordingDetails['location'] as Map<String, dynamic>?;

      final thumbnails = snippet['thumbnails'] as Map<String, dynamic>? ?? {};
      final highThumb = thumbnails['high'] as Map<String, dynamic>?;
      final defaultThumb = thumbnails['default'] as Map<String, dynamic>?;
      final thumbnailUrl =
          (highThumb?['url'] ?? defaultThumb?['url'] ?? '') as String;

      final tags = (snippet['tags'] as List<dynamic>?)
              ?.map((t) => t.toString())
              .toList() ??
          [];

      return VideoModel(
        id: item['id'] as String,
        title: snippet['title'] as String? ?? '',
        channelTitle: snippet['channelTitle'] as String? ?? '',
        thumbnailUrl: thumbnailUrl,
        publishedAt: snippet['publishedAt'] as String? ?? '',
        tags: tags,
        latitude: (location?['latitude'] as num?)?.toDouble(),
        longitude: (location?['longitude'] as num?)?.toDouble(),
        recordingDate: recordingDetails['recordingDate'] as String?,
      );
    }).toList();
  }
}
