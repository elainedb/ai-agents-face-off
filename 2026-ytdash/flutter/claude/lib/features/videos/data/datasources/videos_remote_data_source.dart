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
  final http.Client httpClient;
  final GeocodingService geocodingService;

  VideosRemoteDataSourceImpl({
    required this.httpClient,
    required this.geocodingService,
  });

  @override
  Future<List<VideoModel>> getVideosFromChannels(
      List<String> channelIds) async {
    try {
      // 1. Search all channels in parallel
      final searchResults = await Future.wait(
        channelIds.map((id) => _searchChannel(id)),
      );

      final allVideoIds = searchResults.expand((ids) => ids).toList();
      if (allVideoIds.isEmpty) return [];

      // 2. Fetch video details in batches of 50
      final allVideos = <VideoModel>[];
      for (var i = 0; i < allVideoIds.length; i += 50) {
        final batch = allVideoIds.sublist(
          i,
          i + 50 > allVideoIds.length ? allVideoIds.length : i + 50,
        );
        final videos = await _fetchVideoDetails(batch);
        allVideos.addAll(videos);
      }

      // 3. Reverse geocode videos with coordinates
      await _geocodeVideos(allVideos);

      // 4. Sort by publishedAt descending
      allVideos.sort((a, b) {
        final dateA = DateTime.parse(a.publishedAt);
        final dateB = DateTime.parse(b.publishedAt);
        return dateB.compareTo(dateA);
      });

      return allVideos;
    } catch (e) {
      if (e is ServerException) rethrow;
      throw ServerException('Failed to fetch videos: $e');
    }
  }

  Future<List<String>> _searchChannel(String channelId) async {
    final videoIds = <String>[];
    String? pageToken;

    do {
      final uri = Uri.parse('https://www.googleapis.com/youtube/v3/search').replace(
        queryParameters: {
          'part': 'snippet',
          'channelId': channelId,
          'type': 'video',
          'order': 'date',
          'maxResults': '50',
          'key': Config.youtubeApiKey,
          if (pageToken != null) 'pageToken': pageToken,
        },
      );

      final response = await httpClient.get(uri);
      if (response.statusCode != 200) {
        throw ServerException(
            'YouTube search API error: ${response.statusCode}');
      }

      final data = json.decode(response.body) as Map<String, dynamic>;
      final items = data['items'] as List<dynamic>? ?? [];

      for (final item in items) {
        final id = item['id']?['videoId'] as String?;
        if (id != null) videoIds.add(id);
      }

      pageToken = data['nextPageToken'] as String?;
    } while (pageToken != null);

    return videoIds;
  }

  Future<List<VideoModel>> _fetchVideoDetails(List<String> videoIds) async {
    final uri = Uri.parse('https://www.googleapis.com/youtube/v3/videos').replace(
      queryParameters: {
        'part': 'snippet,recordingDetails',
        'id': videoIds.join(','),
        'key': Config.youtubeApiKey,
      },
    );

    final response = await httpClient.get(uri);
    if (response.statusCode != 200) {
      throw ServerException(
          'YouTube videos API error: ${response.statusCode}');
    }

    final data = json.decode(response.body) as Map<String, dynamic>;
    final items = data['items'] as List<dynamic>? ?? [];

    return items.map((item) {
      final snippet = item['snippet'] as Map<String, dynamic>;
      final recordingDetails =
          item['recordingDetails'] as Map<String, dynamic>? ?? {};
      final location =
          recordingDetails['location'] as Map<String, dynamic>? ?? {};

      final tags = (snippet['tags'] as List<dynamic>?)
              ?.map((t) => t.toString())
              .toList() ??
          [];

      final thumbnails = snippet['thumbnails'] as Map<String, dynamic>? ?? {};
      final thumbnail = thumbnails['high'] as Map<String, dynamic>? ??
          thumbnails['medium'] as Map<String, dynamic>? ??
          thumbnails['default'] as Map<String, dynamic>? ??
          {};

      return VideoModel(
        id: item['id'] as String,
        title: snippet['title'] as String? ?? '',
        channelTitle: snippet['channelTitle'] as String? ?? '',
        thumbnailUrl: thumbnail['url'] as String? ?? '',
        publishedAt: snippet['publishedAt'] as String? ?? '',
        tags: tags,
        latitude: (location['latitude'] as num?)?.toDouble(),
        longitude: (location['longitude'] as num?)?.toDouble(),
        recordingDate: recordingDetails['recordingDate'] as String?,
      );
    }).toList();
  }

  Future<void> _geocodeVideos(List<VideoModel> videos) async {
    final futures = <Future<void>>[];

    for (var i = 0; i < videos.length; i++) {
      final video = videos[i];
      if (video.latitude != null && video.longitude != null) {
        final index = i;
        futures.add(() async {
          final (city, country) = await geocodingService.reverseGeocode(
            video.latitude!,
            video.longitude!,
          );
          videos[index] = video.copyWith(city: city, country: country);
        }());
      }
    }

    await Future.wait(futures);
  }
}
