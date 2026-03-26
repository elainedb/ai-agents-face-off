import 'dart:convert';

import 'package:geocoding/geocoding.dart';
import 'package:http/http.dart' as http;

import '../../../../config/config.dart';
import '../../../../core/error/exceptions.dart';
import '../models/video_model.dart';

abstract class VideosRemoteDataSource {
  Future<List<VideoModel>> getVideosFromChannels(List<String> channelIds);
}

class VideosRemoteDataSourceImpl implements VideosRemoteDataSource {
  const VideosRemoteDataSourceImpl({required this.client});

  final http.Client client;

  @override
  Future<List<VideoModel>> getVideosFromChannels(
    List<String> channelIds,
  ) async {
    try {
      final ids = <String>{};
      for (final channelId in channelIds) {
        String? pageToken;
        do {
          final queryParameters = <String, String>{
            'part': 'snippet',
            'channelId': channelId,
            'type': 'video',
            'order': 'date',
            'maxResults': '50',
            'key': Config.youtubeApiKey,
          };
          if (pageToken != null) {
            queryParameters['pageToken'] = pageToken;
          }
          final uri = Uri.https(
            'www.googleapis.com',
            '/youtube/v3/search',
            queryParameters,
          );
          final response = await client.get(uri);
          if (response.statusCode != 200) {
            throw ServerException(
              'YouTube search request failed with ${response.statusCode}.',
            );
          }
          final body = jsonDecode(response.body) as Map<String, dynamic>;
          final items = (body['items'] as List<dynamic>? ?? []);
          for (final item in items) {
            final id =
                (item as Map<String, dynamic>)['id'] as Map<String, dynamic>?;
            final videoId = id?['videoId'] as String?;
            if (videoId != null && videoId.isNotEmpty) {
              ids.add(videoId);
            }
          }
          pageToken = body['nextPageToken'] as String?;
        } while (pageToken != null && pageToken.isNotEmpty);
      }

      if (ids.isEmpty) {
        return const [];
      }

      final models = <VideoModel>[];
      final idList = ids.toList();
      for (var i = 0; i < idList.length; i += 50) {
        final batchIds = idList.sublist(
          i,
          i + 50 > idList.length ? idList.length : i + 50,
        );
        final uri = Uri.https('www.googleapis.com', '/youtube/v3/videos', {
          'part': 'snippet,recordingDetails',
          'id': batchIds.join(','),
          'key': Config.youtubeApiKey,
        });
        final response = await client.get(uri);
        if (response.statusCode != 200) {
          throw ServerException(
            'YouTube videos request failed with ${response.statusCode}.',
          );
        }

        final body = jsonDecode(response.body) as Map<String, dynamic>;
        final items = (body['items'] as List<dynamic>? ?? []);
        for (final rawItem in items) {
          final item = rawItem as Map<String, dynamic>;
          final snippet = item['snippet'] as Map<String, dynamic>? ?? const {};
          final recordingDetails =
              item['recordingDetails'] as Map<String, dynamic>? ?? const {};
          final location =
              recordingDetails['location'] as Map<String, dynamic>? ?? const {};

          final coordinates = (
            latitude: (location['latitude'] as num?)?.toDouble(),
            longitude: (location['longitude'] as num?)?.toDouble(),
          );
          final place = await _resolvePlace(
            latitude: coordinates.latitude,
            longitude: coordinates.longitude,
            locationDescription:
                recordingDetails['locationDescription'] as String?,
          );

          final thumbnails =
              snippet['thumbnails'] as Map<String, dynamic>? ?? const {};
          final highThumb = thumbnails['high'] as Map<String, dynamic>?;
          final mediumThumb = thumbnails['medium'] as Map<String, dynamic>?;
          final defaultThumb = thumbnails['default'] as Map<String, dynamic>?;

          models.add(
            VideoModel(
              id: item['id'] as String? ?? '',
              title: snippet['title'] as String? ?? 'Untitled video',
              channelTitle:
                  snippet['channelTitle'] as String? ?? 'Unknown channel',
              thumbnailUrl:
                  highThumb?['url'] as String? ??
                  mediumThumb?['url'] as String? ??
                  defaultThumb?['url'] as String? ??
                  '',
              publishedAt:
                  snippet['publishedAt'] as String? ??
                  DateTime.now().toUtc().toIso8601String(),
              tags: (snippet['tags'] as List<dynamic>? ?? const [])
                  .map((tag) => tag.toString())
                  .toList(),
              city: place.city,
              country: place.country,
              latitude: coordinates.latitude,
              longitude: coordinates.longitude,
              recordingDate: recordingDetails['recordingDate'] as String?,
            ),
          );
        }
      }

      models.sort((a, b) => b.publishedAt.compareTo(a.publishedAt));
      return models;
    } on AppException {
      rethrow;
    } on http.ClientException catch (error) {
      throw NetworkException(error.message);
    } catch (error) {
      throw ServerException('Failed to load YouTube videos: $error');
    }
  }

  Future<({String? city, String? country})> _resolvePlace({
    required double? latitude,
    required double? longitude,
    required String? locationDescription,
  }) async {
    if (latitude != null && longitude != null) {
      try {
        final placemarks = await placemarkFromCoordinates(latitude, longitude);
        if (placemarks.isNotEmpty) {
          final placemark = placemarks.first;
          return (
            city: placemark.locality?.isNotEmpty == true
                ? placemark.locality
                : placemark.subAdministrativeArea,
            country: placemark.country,
          );
        }
      } catch (_) {
        // Fall back to the text description below.
      }
    }

    if (locationDescription != null && locationDescription.trim().isNotEmpty) {
      final parts = locationDescription
          .split(',')
          .map((part) => part.trim())
          .where((part) => part.isNotEmpty)
          .toList();
      return (
        city: parts.isNotEmpty ? parts.first : null,
        country: parts.length > 1 ? parts.last : null,
      );
    }

    return (city: null, country: null);
  }
}
