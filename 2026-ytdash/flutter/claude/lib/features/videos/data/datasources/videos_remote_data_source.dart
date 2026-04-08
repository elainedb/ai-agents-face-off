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
  static const _apiKey = Config.youtubeApiKey;

  VideosRemoteDataSourceImpl({
    required this.client,
    required this.geocodingService,
  });

  @override
  Future<List<VideoModel>> getVideosFromChannels(
      List<String> channelIds) async {
    try {
      // Step 1: Search for videos from all channels in parallel
      final searchFutures =
          channelIds.map((id) => _searchChannelVideos(id)).toList();
      final searchResults = await Future.wait(searchFutures);
      final allVideoIds = searchResults.expand((ids) => ids).toList();

      if (allVideoIds.isEmpty) return [];

      // Step 2: Fetch video details in batches of 50
      final videoModels = await _fetchVideoDetails(allVideoIds);

      // Step 3: Geocode videos with coordinates
      await _geocodeVideos(videoModels);

      // Step 4: Sort by publishedAt descending
      videoModels.sort((a, b) => b.publishedAt.compareTo(a.publishedAt));

      return videoModels;
    } catch (e) {
      if (e is ServerException) rethrow;
      throw ServerException('Failed to fetch videos: $e');
    }
  }

  Future<List<String>> _searchChannelVideos(String channelId) async {
    final videoIds = <String>[];
    String? pageToken;

    do {
      final uri = Uri.parse('https://www.googleapis.com/youtube/v3/search'
          '?part=snippet'
          '&channelId=$channelId'
          '&type=video'
          '&order=date'
          '&maxResults=50'
          '&key=$_apiKey'
          '${pageToken != null ? '&pageToken=$pageToken' : ''}');

      final response = await client.get(uri);
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
    final models = <VideoModel>[];

    for (int i = 0; i < videoIds.length; i += 50) {
      final batch = videoIds.sublist(
          i, i + 50 > videoIds.length ? videoIds.length : i + 50);
      final ids = batch.join(',');
      final uri = Uri.parse('https://www.googleapis.com/youtube/v3/videos'
          '?part=snippet,recordingDetails'
          '&id=$ids'
          '&key=$_apiKey');

      final response = await client.get(uri);
      if (response.statusCode != 200) {
        throw ServerException(
            'YouTube videos API error: ${response.statusCode}');
      }

      final data = json.decode(response.body) as Map<String, dynamic>;
      final items = data['items'] as List<dynamic>? ?? [];

      for (final item in items) {
        final snippet = item['snippet'] as Map<String, dynamic>? ?? {};
        final recordingDetails =
            item['recordingDetails'] as Map<String, dynamic>? ?? {};
        final location =
            recordingDetails['location'] as Map<String, dynamic>? ?? {};
        final thumbnails = snippet['thumbnails'] as Map<String, dynamic>? ?? {};
        final highThumb = thumbnails['high'] as Map<String, dynamic>? ??
            thumbnails['medium'] as Map<String, dynamic>? ??
            thumbnails['default'] as Map<String, dynamic>? ??
            {};

        models.add(VideoModel(
          id: item['id'] as String,
          title: snippet['title'] as String? ?? '',
          channelTitle: snippet['channelTitle'] as String? ?? '',
          thumbnailUrl: highThumb['url'] as String? ?? '',
          publishedAt: snippet['publishedAt'] as String? ?? '',
          tags: (snippet['tags'] as List<dynamic>?)
                  ?.map((t) => t.toString())
                  .toList() ??
              [],
          latitude: (location['latitude'] as num?)?.toDouble(),
          longitude: (location['longitude'] as num?)?.toDouble(),
          recordingDate: recordingDetails['recordingDate'] as String?,
        ));
      }
    }

    return models;
  }

  Future<void> _geocodeVideos(List<VideoModel> videos) async {
    final geocodeFutures = <Future<void>>[];

    for (int i = 0; i < videos.length; i++) {
      final video = videos[i];
      if (video.latitude != null && video.longitude != null) {
        final index = i;
        geocodeFutures.add(() async {
          final (city, country) = await geocodingService.reverseGeocode(
            video.latitude!,
            video.longitude!,
          );
          videos[index] = video.copyWith(city: city, country: country);
        }());
      }
    }

    await Future.wait(geocodeFutures);
  }
}
