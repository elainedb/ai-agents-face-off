import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:injectable/injectable.dart';

import '../../../../config/config.dart';
import '../../../../core/error/exceptions.dart';
import '../models/video_model.dart';
import '../services/geocoding_service.dart';

abstract class VideosRemoteDataSource {
  Future<List<VideoModel>> getVideosFromChannels(List<String> channelIds);
}

@LazySingleton(as: VideosRemoteDataSource)
class VideosRemoteDataSourceImpl implements VideosRemoteDataSource {
  VideosRemoteDataSourceImpl(this._client, this._geocodingService);

  final http.Client _client;
  final GeocodingService _geocodingService;

  @override
  Future<List<VideoModel>> getVideosFromChannels(List<String> channelIds) async {
    try {
      final videoIdsPerChannel = await Future.wait<List<String>>(
        channelIds.map(_fetchAllVideoIdsForChannel),
      );
      final videoIds = videoIdsPerChannel.expand((ids) => ids).toSet().toList();
      if (videoIds.isEmpty) {
        return <VideoModel>[];
      }

      final videos = <VideoModel>[];
      for (var index = 0; index < videoIds.length; index += 50) {
        final batchIds = videoIds.skip(index).take(50).toList();
        videos.addAll(await _fetchVideoDetails(batchIds));
      }

      final resolvedVideos = await Future.wait<VideoModel>(
        videos.map((video) async {
          if (video.latitude == null || video.longitude == null) {
            return video;
          }
          final location = await _geocodingService.resolveLocation(
            latitude: video.latitude,
            longitude: video.longitude,
          );
          return video.copyWith(city: location.$1, country: location.$2);
        }),
      );

      resolvedVideos.sort(
        (left, right) => DateTime.parse(right.publishedAt).compareTo(
          DateTime.parse(left.publishedAt),
        ),
      );
      return resolvedVideos;
    } catch (error) {
      if (error is AppException) {
        rethrow;
      }
      throw ServerException('Failed to fetch videos: $error');
    }
  }

  Future<List<String>> _fetchAllVideoIdsForChannel(String channelId) async {
    final videoIds = <String>[];
    String? pageToken;

    do {
      final query = <String, String>{
        'part': 'snippet',
        'channelId': channelId,
        'type': 'video',
        'order': 'date',
        'maxResults': '50',
        'key': Config.youtubeApiKey,
      };
      if (pageToken != null) {
        query['pageToken'] = pageToken;
      }

      final response = await _client.get(
        Uri.https('www.googleapis.com', '/youtube/v3/search', query),
      );
      if (response.statusCode != 200) {
        throw ServerException('YouTube search API failed for channel $channelId.');
      }
      final json = jsonDecode(response.body) as Map<String, dynamic>;
      final items = (json['items'] as List<dynamic>? ?? <dynamic>[]);
      for (final item in items) {
        final id = (item as Map<String, dynamic>)['id'] as Map<String, dynamic>?;
        final videoId = id?['videoId'] as String?;
        if (videoId != null && videoId.isNotEmpty) {
          videoIds.add(videoId);
        }
      }
      pageToken = json['nextPageToken'] as String?;
    } while (pageToken != null && pageToken.isNotEmpty);

    return videoIds;
  }

  Future<List<VideoModel>> _fetchVideoDetails(List<String> videoIds) async {
    final response = await _client.get(
      Uri.https(
        'www.googleapis.com',
        '/youtube/v3/videos',
        <String, String>{
          'part': 'snippet,recordingDetails',
          'id': videoIds.join(','),
          'key': Config.youtubeApiKey,
        },
      ),
    );

    if (response.statusCode != 200) {
      throw const ServerException('YouTube videos API failed.');
    }

    final json = jsonDecode(response.body) as Map<String, dynamic>;
    final items = (json['items'] as List<dynamic>? ?? <dynamic>[]);
    return items.map((item) => _videoFromApi(item as Map<String, dynamic>)).toList();
  }

  VideoModel _videoFromApi(Map<String, dynamic> json) {
    final snippet = json['snippet'] as Map<String, dynamic>? ?? <String, dynamic>{};
    final recordingDetails =
        json['recordingDetails'] as Map<String, dynamic>? ?? <String, dynamic>{};
    final thumbnails = snippet['thumbnails'] as Map<String, dynamic>? ?? <String, dynamic>{};
    final bestThumbnail = (thumbnails['high'] ??
            thumbnails['medium'] ??
            thumbnails['default']) as Map<String, dynamic>? ??
        <String, dynamic>{};
    final location = recordingDetails['location'] as Map<String, dynamic>?;
    final recordingDate = recordingDetails['recordingDate'] as String?;

    return VideoModel(
      id: json['id'] as String,
      title: snippet['title'] as String? ?? 'Untitled',
      channelTitle: snippet['channelTitle'] as String? ?? 'Unknown channel',
      thumbnailUrl: bestThumbnail['url'] as String? ?? '',
      publishedAt: snippet['publishedAt'] as String? ?? DateTime.now().toIso8601String(),
      tags: (snippet['tags'] as List<dynamic>? ?? <dynamic>[]).cast<String>(),
      latitude: (location?['latitude'] as num?)?.toDouble(),
      longitude: (location?['longitude'] as num?)?.toDouble(),
      recordingDate: recordingDate,
    );
  }
}
