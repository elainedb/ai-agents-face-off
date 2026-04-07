import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../../../config/config.dart';
import '../../../../core/error/exceptions.dart';
import '../models/video_model.dart';
import '../services/geocoding_service.dart';

abstract class VideosRemoteDataSource {
  Future<List<VideoModel>> getVideosFromChannels(List<String> channelIds);
}

class VideosRemoteDataSourceImpl implements VideosRemoteDataSource {
  VideosRemoteDataSourceImpl({
    required this.client,
    required this.geocodingService,
  });

  final http.Client client;
  final GeocodingService geocodingService;

  @override
  Future<List<VideoModel>> getVideosFromChannels(
    List<String> channelIds,
  ) async {
    try {
      final List<List<String>> allVideoIds = await Future.wait<List<String>>(
        channelIds.map(_fetchVideoIdsForChannel),
      );
      final List<String> videoIds = allVideoIds
          .expand((List<String> ids) => ids)
          .toSet()
          .toList();
      final List<VideoModel> videos = <VideoModel>[];

      for (int index = 0; index < videoIds.length; index += 50) {
        final List<String> batch = videoIds.skip(index).take(50).toList();
        videos.addAll(await _fetchVideoDetails(batch));
      }

      final List<VideoModel> resolved = await _resolveLocations(videos);
      resolved.sort(
        (VideoModel a, VideoModel b) => b.publishedAt.compareTo(a.publishedAt),
      );
      return resolved;
    } on ServerException {
      rethrow;
    } on NetworkException {
      rethrow;
    } catch (error) {
      throw ServerException('Unable to fetch videos: $error');
    }
  }

  Future<List<String>> _fetchVideoIdsForChannel(String channelId) async {
    final List<String> ids = <String>[];
    String? pageToken;

    do {
      final Uri uri = Uri.https(
        'www.googleapis.com',
        '/youtube/v3/search',
        <String, String>{
          'part': 'snippet',
          'channelId': channelId,
          'type': 'video',
          'order': 'date',
          'maxResults': '50',
          'pageToken': pageToken ?? '',
          'key': Config.youtubeApiKey,
        },
      );

      final http.Response response = await client.get(uri);
      if (response.statusCode != 200) {
        throw ServerException(
          'YouTube search request failed with status ${response.statusCode}.',
        );
      }

      final Map<String, dynamic> json =
          jsonDecode(response.body) as Map<String, dynamic>;
      final List<dynamic> items =
          json['items'] as List<dynamic>? ?? <dynamic>[];
      for (final dynamic item in items) {
        final Map<String, dynamic> map = item as Map<String, dynamic>;
        final Map<String, dynamic>? id = map['id'] as Map<String, dynamic>?;
        final String? videoId = id?['videoId'] as String?;
        if (videoId != null && videoId.isNotEmpty) {
          ids.add(videoId);
        }
      }
      pageToken = json['nextPageToken'] as String?;
    } while (pageToken != null && pageToken.isNotEmpty);

    return ids;
  }

  Future<List<VideoModel>> _fetchVideoDetails(List<String> videoIds) async {
    final Uri uri =
        Uri.https('www.googleapis.com', '/youtube/v3/videos', <String, String>{
          'part': 'snippet,recordingDetails',
          'id': videoIds.join(','),
          'key': Config.youtubeApiKey,
        });

    final http.Response response = await client.get(uri);
    if (response.statusCode != 200) {
      throw ServerException(
        'YouTube videos request failed with status ${response.statusCode}.',
      );
    }

    final Map<String, dynamic> json =
        jsonDecode(response.body) as Map<String, dynamic>;
    final List<dynamic> items = json['items'] as List<dynamic>? ?? <dynamic>[];

    return items.map((dynamic item) {
      final Map<String, dynamic> map = item as Map<String, dynamic>;
      final Map<String, dynamic> snippet =
          map['snippet'] as Map<String, dynamic>? ?? <String, dynamic>{};
      final Map<String, dynamic> recordingDetails =
          map['recordingDetails'] as Map<String, dynamic>? ??
          <String, dynamic>{};
      final Map<String, dynamic> thumbnails =
          snippet['thumbnails'] as Map<String, dynamic>? ?? <String, dynamic>{};
      final Map<String, dynamic>? high =
          thumbnails['high'] as Map<String, dynamic>?;
      final Map<String, dynamic>? medium =
          thumbnails['medium'] as Map<String, dynamic>?;
      final Map<String, dynamic>? defaultThumb =
          thumbnails['default'] as Map<String, dynamic>?;
      final Map<String, dynamic>? location =
          recordingDetails['location'] as Map<String, dynamic>?;

      return VideoModel(
        id: map['id'] as String? ?? '',
        title: snippet['title'] as String? ?? 'Untitled video',
        channelTitle: snippet['channelTitle'] as String? ?? 'Unknown channel',
        thumbnailUrl:
            high?['url'] as String? ??
            medium?['url'] as String? ??
            defaultThumb?['url'] as String? ??
            '',
        publishedAt:
            snippet['publishedAt'] as String? ??
            DateTime.now().toIso8601String(),
        tags: (snippet['tags'] as List<dynamic>? ?? <dynamic>[])
            .map((dynamic value) => value.toString())
            .toList(),
        latitude: (location?['latitude'] as num?)?.toDouble(),
        longitude: (location?['longitude'] as num?)?.toDouble(),
        recordingDate: recordingDetails['recordingDate'] as String?,
        locationDescription: recordingDetails['locationDescription'] as String?,
      );
    }).toList();
  }

  Future<List<VideoModel>> _resolveLocations(List<VideoModel> videos) async {
    final List<VideoModel> resolved = <VideoModel>[];

    for (int index = 0; index < videos.length; index += 5) {
      final List<VideoModel> chunk = videos.skip(index).take(5).toList();
      final List<VideoModel> chunkResults = await Future.wait<VideoModel>(
        chunk.map((VideoModel video) async {
          if (video.latitude == null || video.longitude == null) {
            return video;
          }
          final GeocodingResult location = await geocodingService.resolve(
            latitude: video.latitude!,
            longitude: video.longitude!,
            locationDescription: video.locationDescription,
          );
          return video.copyWith(city: location.city, country: location.country);
        }),
      );
      resolved.addAll(chunkResults);
    }

    return resolved;
  }
}
