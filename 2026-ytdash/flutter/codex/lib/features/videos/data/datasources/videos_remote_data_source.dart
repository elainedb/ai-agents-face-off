import 'dart:convert';

import 'package:geocoding/geocoding.dart';
import 'package:http/http.dart' as http;
import 'package:injectable/injectable.dart';

import '../../../../config/config.dart';
import '../../../../core/error/exceptions.dart';
import '../models/video_model.dart';

abstract class VideosRemoteDataSource {
  Future<List<VideoModel>> getVideosFromChannels(List<String> channelIds);
}

@LazySingleton(as: VideosRemoteDataSource)
class VideosRemoteDataSourceImpl implements VideosRemoteDataSource {
  VideosRemoteDataSourceImpl(this._client);

  final http.Client _client;

  @override
  Future<List<VideoModel>> getVideosFromChannels(
    List<String> channelIds,
  ) async {
    try {
      final videoIds = <String>{};
      for (final channelId in channelIds) {
        String? nextPageToken;
        do {
          final queryParameters = <String, String>{
            'part': 'snippet',
            'channelId': channelId,
            'type': 'video',
            'order': 'date',
            'maxResults': '50',
            'key': Config.youtubeApiKey,
          };
          if (nextPageToken != null) {
            queryParameters['pageToken'] = nextPageToken;
          }

          final uri = Uri.https(
            'www.googleapis.com',
            '/youtube/v3/search',
            queryParameters,
          );

          final response = await _client.get(uri);
          if (response.statusCode != 200) {
            throw ServerException(
              'Failed to fetch search results (${response.statusCode}).',
            );
          }

          final body = jsonDecode(response.body) as Map<String, dynamic>;
          final items = (body['items'] as List<dynamic>? ?? <dynamic>[]);
          for (final item in items) {
            final id =
                ((item as Map<String, dynamic>)['id']
                    as Map<String, dynamic>)['videoId'];
            if (id is String && id.isNotEmpty) {
              videoIds.add(id);
            }
          }
          nextPageToken = body['nextPageToken'] as String?;
        } while (nextPageToken != null && nextPageToken.isNotEmpty);
      }

      final videos = <VideoModel>[];
      final ids = videoIds.toList();
      for (var i = 0; i < ids.length; i += 50) {
        final batch = ids.skip(i).take(50).toList();
        final uri = Uri.https(
          'www.googleapis.com',
          '/youtube/v3/videos',
          <String, String>{
            'part': 'snippet,recordingDetails',
            'id': batch.join(','),
            'key': Config.youtubeApiKey,
          },
        );

        final response = await _client.get(uri);
        if (response.statusCode != 200) {
          throw ServerException(
            'Failed to fetch video details (${response.statusCode}).',
          );
        }

        final body = jsonDecode(response.body) as Map<String, dynamic>;
        final items = (body['items'] as List<dynamic>? ?? <dynamic>[]);
        for (final item in items.cast<Map<String, dynamic>>()) {
          videos.add(await _buildVideoModel(item));
        }
      }

      videos.sort(
        (a, b) => DateTime.parse(
          b.publishedAt,
        ).compareTo(DateTime.parse(a.publishedAt)),
      );
      return videos;
    } on AppException {
      rethrow;
    } catch (error) {
      throw ServerException('Failed to fetch videos: $error');
    }
  }

  Future<VideoModel> _buildVideoModel(Map<String, dynamic> item) async {
    final snippet =
        item['snippet'] as Map<String, dynamic>? ?? <String, dynamic>{};
    final thumbnails =
        snippet['thumbnails'] as Map<String, dynamic>? ?? <String, dynamic>{};
    final highThumbnail = thumbnails['high'] as Map<String, dynamic>?;
    final mediumThumbnail = thumbnails['medium'] as Map<String, dynamic>?;
    final defaultThumbnail = thumbnails['default'] as Map<String, dynamic>?;
    final recordingDetails =
        item['recordingDetails'] as Map<String, dynamic>? ??
        <String, dynamic>{};
    final location = recordingDetails['location'] as Map<String, dynamic>?;
    final locationDescription =
        recordingDetails['locationDescription'] as String?;

    String? city;
    String? country;
    final latitude = (location?['latitude'] as num?)?.toDouble();
    final longitude = (location?['longitude'] as num?)?.toDouble();

    if (latitude != null && longitude != null) {
      final geo = await _reverseGeocode(latitude, longitude);
      city = geo.$1;
      country = geo.$2;
    }

    if ((city == null || country == null) && locationDescription != null) {
      final parts = locationDescription
          .split(',')
          .map((part) => part.trim())
          .where((part) => part.isNotEmpty)
          .toList();
      city ??= parts.isNotEmpty ? parts.first : null;
      country ??= parts.length > 1 ? parts.last : null;
    }

    return VideoModel(
      id: item['id'] as String,
      title: snippet['title'] as String? ?? 'Untitled Video',
      channelTitle: snippet['channelTitle'] as String? ?? 'Unknown Channel',
      thumbnailUrl:
          (highThumbnail?['url'] ??
                  mediumThumbnail?['url'] ??
                  defaultThumbnail?['url'] ??
                  '')
              .toString(),
      publishedAt:
          snippet['publishedAt'] as String? ??
          DateTime.fromMillisecondsSinceEpoch(0).toIso8601String(),
      tags: (snippet['tags'] as List<dynamic>? ?? <dynamic>[])
          .map((tag) => tag.toString())
          .toList(),
      city: city,
      country: country,
      latitude: latitude,
      longitude: longitude,
      recordingDate: recordingDetails['recordingDate'] as String?,
    );
  }

  Future<(String?, String?)> _reverseGeocode(
    double latitude,
    double longitude,
  ) async {
    try {
      final placemarks = await placemarkFromCoordinates(latitude, longitude);
      if (placemarks.isEmpty) {
        return (null, null);
      }

      final placemark = placemarks.first;
      return (
        placemark.locality?.isNotEmpty == true
            ? placemark.locality
            : placemark.subAdministrativeArea,
        placemark.country,
      );
    } catch (_) {
      return (null, null);
    }
  }
}
