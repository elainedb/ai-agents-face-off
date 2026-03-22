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
  VideosRemoteDataSourceImpl({required this.client});

  final http.Client client;

  @override
  Future<List<VideoModel>> getVideosFromChannels(
    List<String> channelIds,
  ) async {
    try {
      final allVideoIds = <String>{};
      for (final channelId in channelIds) {
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
          final response = await client.get(uri);
          if (response.statusCode != 200) {
            throw ServerException(
              'YouTube search failed with ${response.statusCode}.',
            );
          }
          final decoded = jsonDecode(response.body) as Map<String, dynamic>;
          final items = (decoded['items'] as List<dynamic>? ?? const []);
          for (final item in items) {
            final map = item as Map<String, dynamic>;
            final id =
                (map['id'] as Map<String, dynamic>)['videoId'] as String?;
            if (id != null && id.isNotEmpty) {
              allVideoIds.add(id);
            }
          }
          pageToken = decoded['nextPageToken'] as String?;
        } while (pageToken != null);
      }

      if (allVideoIds.isEmpty) {
        return const <VideoModel>[];
      }

      final videos = <VideoModel>[];
      final ids = allVideoIds.toList();
      for (var i = 0; i < ids.length; i += 50) {
        final batch = ids.skip(i).take(50).toList();
        final uri = Uri.https('www.googleapis.com', '/youtube/v3/videos', {
          'part': 'snippet,recordingDetails',
          'id': batch.join(','),
          'key': Config.youtubeApiKey,
        });
        final response = await client.get(uri);
        if (response.statusCode != 200) {
          throw ServerException(
            'YouTube video details failed with ${response.statusCode}.',
          );
        }
        final decoded = jsonDecode(response.body) as Map<String, dynamic>;
        final items = (decoded['items'] as List<dynamic>? ?? const []);
        for (final item in items) {
          final map = item as Map<String, dynamic>;
          videos.add(await _toVideoModel(map));
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
      throw ServerException('Failed to load videos. $error');
    }
  }

  Future<VideoModel> _toVideoModel(Map<String, dynamic> map) async {
    final snippet = map['snippet'] as Map<String, dynamic>? ?? const {};
    final recordingDetails =
        map['recordingDetails'] as Map<String, dynamic>? ?? const {};
    final location = recordingDetails['location'] as Map<String, dynamic>?;
    final latitude = (location?['latitude'] as num?)?.toDouble();
    final longitude = (location?['longitude'] as num?)?.toDouble();
    final description = recordingDetails['locationDescription'] as String?;

    final resolvedLocation = await _resolveLocation(
      latitude: latitude,
      longitude: longitude,
      description: description,
    );

    final thumbnails =
        snippet['thumbnails'] as Map<String, dynamic>? ?? const {};
    final thumbnailUrl =
        (thumbnails['high'] as Map<String, dynamic>?)?['url'] as String? ??
        (thumbnails['medium'] as Map<String, dynamic>?)?['url'] as String? ??
        (thumbnails['default'] as Map<String, dynamic>?)?['url'] as String? ??
        '';

    return VideoModel(
      id: map['id'] as String,
      title: snippet['title'] as String? ?? 'Untitled video',
      channelTitle: snippet['channelTitle'] as String? ?? 'Unknown channel',
      thumbnailUrl: thumbnailUrl,
      publishedAt:
          snippet['publishedAt'] as String? ?? DateTime.now().toIso8601String(),
      tags: (snippet['tags'] as List<dynamic>? ?? const []).cast<String>(),
      city: resolvedLocation.$1,
      country: resolvedLocation.$2,
      latitude: latitude,
      longitude: longitude,
      recordingDate: recordingDetails['recordingDate'] as String?,
    );
  }

  Future<(String?, String?)> _resolveLocation({
    required double? latitude,
    required double? longitude,
    required String? description,
  }) async {
    if (latitude != null && longitude != null) {
      try {
        final placemarks = await placemarkFromCoordinates(latitude, longitude);
        if (placemarks.isNotEmpty) {
          final placemark = placemarks.first;
          return (placemark.locality, placemark.country);
        }
      } catch (_) {
        // Fall back to parsing the location description below.
      }
    }

    if (description == null || description.trim().isEmpty) {
      return (null, null);
    }

    final parts = description
        .split(',')
        .map((item) => item.trim())
        .where((item) => item.isNotEmpty)
        .toList();
    if (parts.isEmpty) {
      return (null, null);
    }
    if (parts.length == 1) {
      return (parts.first, null);
    }
    return (parts.first, parts.last);
  }
}
