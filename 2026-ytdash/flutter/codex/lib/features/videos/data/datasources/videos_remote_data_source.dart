import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../../../config/config.dart';
import '../../../../core/error/exceptions.dart';
import '../models/video_model.dart';
import 'geocoding_service.dart';

abstract class VideosRemoteDataSource {
  Future<List<VideoModel>> getVideosFromChannels(List<String> channelIds);
}

class VideosRemoteDataSourceImpl implements VideosRemoteDataSource {
  VideosRemoteDataSourceImpl({
    required http.Client client,
    required GeocodingService geocodingService,
  }) : _client = client,
       _geocodingService = geocodingService;

  final http.Client _client;
  final GeocodingService _geocodingService;

  @override
  Future<List<VideoModel>> getVideosFromChannels(List<String> channelIds) async {
    try {
      final idsByChannel = await Future.wait(
        channelIds.map(_fetchVideoIdsForChannel),
      );
      final videoIds = idsByChannel.expand((items) => items).toSet().toList();
      if (videoIds.isEmpty) {
        return const [];
      }

      final models = <VideoModel>[];
      for (var index = 0; index < videoIds.length; index += 50) {
        final batch = videoIds.sublist(
          index,
          index + 50 > videoIds.length ? videoIds.length : index + 50,
        );
        models.addAll(await _fetchVideoDetails(batch));
      }

      final geoTargets = models
          .where((video) => video.hasCoordinates)
          .map((video) => (
                video.latitude!,
                video.longitude!,
                video.locationDescription,
              ));
      final locations = await _geocodingService.resolveBatch(geoTargets);
      final enriched = models.map((video) {
        if (!video.hasCoordinates) {
          return video;
        }
        final key =
            '${video.latitude!.toStringAsFixed(3)},${video.longitude!.toStringAsFixed(3)}';
        final location = locations[key];
        return video.copyWith(
          city: location?.city ?? video.city,
          country: location?.country ?? video.country,
        );
      }).toList()
        ..sort((a, b) => b.publishedAt.compareTo(a.publishedAt));

      return enriched;
    } catch (error) {
      if (error is ServerException) {
        rethrow;
      }
      throw ServerException('Unable to fetch videos: $error');
    }
  }

  Future<List<String>> _fetchVideoIdsForChannel(String channelId) async {
    final ids = <String>[];
    String? pageToken;

    do {
      final uri = Uri.https('www.googleapis.com', '/youtube/v3/search', {
        'part': 'snippet',
        'channelId': channelId,
        'type': 'video',
        'order': 'date',
        'maxResults': '50',
        'key': Config.youtubeApiKey,
        'pageToken': pageToken,
      });
      final response = await _client.get(uri);
      if (response.statusCode != 200) {
        throw ServerException('YouTube search API failed (${response.statusCode}).');
      }

      final data = jsonDecode(response.body) as Map<String, dynamic>;
      final items = (data['items'] as List<dynamic>? ?? const []);
      for (final item in items) {
        final id = (item as Map<String, dynamic>)['id'] as Map<String, dynamic>?;
        final videoId = id?['videoId']?.toString();
        if (videoId != null && videoId.isNotEmpty) {
          ids.add(videoId);
        }
      }
      pageToken = data['nextPageToken']?.toString();
    } while (pageToken != null && pageToken.isNotEmpty);

    return ids;
  }

  Future<List<VideoModel>> _fetchVideoDetails(List<String> ids) async {
    final uri = Uri.https('www.googleapis.com', '/youtube/v3/videos', {
      'part': 'snippet,recordingDetails',
      'id': ids.join(','),
      'key': Config.youtubeApiKey,
      'maxResults': '50',
    });
    final response = await _client.get(uri);
    if (response.statusCode != 200) {
      throw ServerException('YouTube videos API failed (${response.statusCode}).');
    }

    final data = jsonDecode(response.body) as Map<String, dynamic>;
    final items = (data['items'] as List<dynamic>? ?? const []);

    return items.map((item) {
      final map = item as Map<String, dynamic>;
      final snippet = map['snippet'] as Map<String, dynamic>? ?? const {};
      final recording = map['recordingDetails'] as Map<String, dynamic>? ?? const {};
      final thumbnails = snippet['thumbnails'] as Map<String, dynamic>? ?? const {};
      final chosenThumbnail = (thumbnails['high'] ??
              thumbnails['medium'] ??
              thumbnails['default']) as Map<String, dynamic>? ??
          const {};
      final location = recording['location'] as Map<String, dynamic>?;

      return VideoModel(
        id: map['id']?.toString() ?? '',
        title: snippet['title']?.toString() ?? 'Untitled video',
        channelTitle: snippet['channelTitle']?.toString() ?? 'Unknown channel',
        thumbnailUrl: chosenThumbnail['url']?.toString() ?? '',
        publishedAtRaw: snippet['publishedAt']?.toString() ??
            DateTime.now().toUtc().toIso8601String(),
        tags: (snippet['tags'] as List<dynamic>? ?? const [])
            .map((tag) => tag.toString())
            .toList(),
        latitude: (location?['latitude'] as num?)?.toDouble(),
        longitude: (location?['longitude'] as num?)?.toDouble(),
        recordingDateRaw: recording['recordingDate']?.toString(),
        locationDescription: recording['locationDescription']?.toString(),
      );
    }).where((video) => video.id.isNotEmpty).toList();
  }
}
