import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:injectable/injectable.dart';
import 'package:ytdash_flutter_claude/config/config.dart';
import 'package:ytdash_flutter_claude/core/error/exceptions.dart';
import 'package:ytdash_flutter_claude/features/videos/data/models/video_model.dart';

abstract class VideosRemoteDataSource {
  Future<List<VideoModel>> getVideosFromChannels(List<String> channelIds);
}

@LazySingleton(as: VideosRemoteDataSource)
class VideosRemoteDataSourceImpl implements VideosRemoteDataSource {
  final http.Client client;
  static const _baseUrl = 'https://www.googleapis.com/youtube/v3';

  VideosRemoteDataSourceImpl({required this.client});

  @override
  Future<List<VideoModel>> getVideosFromChannels(
      List<String> channelIds) async {
    try {
      final allVideoIds = <String>[];

      for (final channelId in channelIds) {
        String? pageToken;
        do {
          final uri = Uri.parse('$_baseUrl/search').replace(
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

          final response = await client.get(uri);
          if (response.statusCode != 200) {
            throw ServerException(
                'YouTube API error: ${response.statusCode} ${response.body}');
          }

          final data = json.decode(response.body) as Map<String, dynamic>;
          final items = data['items'] as List<dynamic>? ?? [];

          for (final item in items) {
            final videoId = item['id']?['videoId'] as String?;
            if (videoId != null) {
              allVideoIds.add(videoId);
            }
          }

          pageToken = data['nextPageToken'] as String?;
        } while (pageToken != null);
      }

      if (allVideoIds.isEmpty) return [];

      final allVideos = <VideoModel>[];

      // Batch video IDs in groups of 50
      for (var i = 0; i < allVideoIds.length; i += 50) {
        final batch = allVideoIds.skip(i).take(50).toList();
        final uri = Uri.parse('$_baseUrl/videos').replace(
          queryParameters: {
            'part': 'snippet,recordingDetails',
            'id': batch.join(','),
            'key': Config.youtubeApiKey,
          },
        );

        final response = await client.get(uri);
        if (response.statusCode != 200) {
          throw ServerException(
              'YouTube API error: ${response.statusCode} ${response.body}');
        }

        final data = json.decode(response.body) as Map<String, dynamic>;
        final items = data['items'] as List<dynamic>? ?? [];

        for (final item in items) {
          final snippet = item['snippet'] as Map<String, dynamic>? ?? {};
          final recordingDetails =
              item['recordingDetails'] as Map<String, dynamic>? ?? {};
          final location =
              recordingDetails['location'] as Map<String, dynamic>?;

          final lat = location?['latitude'] as double?;
          final lng = location?['longitude'] as double?;

          String? city;
          String? country;

          if (lat != null && lng != null) {
            final geo = await _reverseGeocode(lat, lng);
            city = geo['city'];
            country = geo['country'];

            // Fallback to locationDescription if geocoding returned nothing
            if (city == null && country == null) {
              final locationDesc =
                  recordingDetails['locationDescription'] as String?;
              if (locationDesc != null && locationDesc.contains(',')) {
                final parts = locationDesc.split(',');
                city = parts.first.trim();
                country = parts.last.trim();
              }
            }
          }

          final thumbnails =
              snippet['thumbnails'] as Map<String, dynamic>? ?? {};
          final high = thumbnails['high'] as Map<String, dynamic>?;
          final medium = thumbnails['medium'] as Map<String, dynamic>?;
          final defaultThumb =
              thumbnails['default'] as Map<String, dynamic>?;
          final thumbnailUrl = (high?['url'] ??
                  medium?['url'] ??
                  defaultThumb?['url'] ??
                  '') as String;

          allVideos.add(VideoModel(
            id: item['id'] as String,
            title: snippet['title'] as String? ?? '',
            channelTitle: snippet['channelTitle'] as String? ?? '',
            thumbnailUrl: thumbnailUrl,
            publishedAt: snippet['publishedAt'] as String? ?? '',
            tags: (snippet['tags'] as List<dynamic>?)
                    ?.map((t) => t.toString())
                    .toList() ??
                [],
            city: city,
            country: country,
            latitude: lat,
            longitude: lng,
            recordingDate: recordingDetails['recordingDate'] as String?,
          ));
        }
      }

      allVideos.sort((a, b) => b.publishedAt.compareTo(a.publishedAt));
      return allVideos;
    } on ServerException {
      rethrow;
    } catch (e) {
      throw ServerException('Failed to fetch videos: $e');
    }
  }

  Future<Map<String, String?>> _reverseGeocode(
      double lat, double lng) async {
    try {
      final uri = Uri.parse(
          'https://nominatim.openstreetmap.org/reverse')
          .replace(queryParameters: {
        'lat': lat.toString(),
        'lon': lng.toString(),
        'format': 'json',
        'accept-language': 'en',
      });

      final response = await client.get(uri, headers: {
        'User-Agent': 'ytdash_flutter_claude/1.0',
      });

      if (response.statusCode != 200) {
        return {'city': null, 'country': null};
      }

      final data = json.decode(response.body) as Map<String, dynamic>;
      final address = data['address'] as Map<String, dynamic>?;
      if (address == null) {
        return {'city': null, 'country': null};
      }

      final city = address['city'] as String? ??
          address['town'] as String? ??
          address['village'] as String? ??
          address['municipality'] as String?;
      final country = address['country'] as String?;

      return {'city': city, 'country': country};
    } catch (_) {
      return {'city': null, 'country': null};
    }
  }
}
