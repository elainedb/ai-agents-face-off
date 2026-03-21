import 'dart:convert';

import 'package:geocoding/geocoding.dart';
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

  VideosRemoteDataSourceImpl({required this.client});

  @override
  Future<List<VideoModel>> getVideosFromChannels(
      List<String> channelIds) async {
    try {
      final allVideoIds = <String>[];

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
            // ignore: use_null_aware_elements
            if (pageToken != null) 'pageToken': pageToken,
          });

          final response = await client.get(uri);
          if (response.statusCode != 200) {
            throw ServerException(
                'YouTube API error: ${response.statusCode} - ${response.body}');
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
        final uri = Uri.https('www.googleapis.com', '/youtube/v3/videos', {
          'part': 'snippet,recordingDetails',
          'id': batch.join(','),
          'key': Config.youtubeApiKey,
        });

        final response = await client.get(uri);
        if (response.statusCode != 200) {
          throw ServerException(
              'YouTube API error: ${response.statusCode} - ${response.body}');
        }

        final data = json.decode(response.body) as Map<String, dynamic>;
        final items = data['items'] as List<dynamic>? ?? [];

        for (final item in items) {
          final snippet = item['snippet'] as Map<String, dynamic>? ?? {};
          final recordingDetails =
              item['recordingDetails'] as Map<String, dynamic>? ?? {};

          final tags =
              (snippet['tags'] as List<dynamic>?)?.cast<String>() ?? [];
          final thumbnails =
              snippet['thumbnails'] as Map<String, dynamic>? ?? {};
          final high = thumbnails['high'] as Map<String, dynamic>? ?? {};
          final medium = thumbnails['medium'] as Map<String, dynamic>? ?? {};
          final thumbnailUrl = (high['url'] ?? medium['url'] ?? '') as String;

          final location =
              recordingDetails['location'] as Map<String, dynamic>?;
          final lat = location?['latitude'] as double?;
          final lng = location?['longitude'] as double?;
          final recordingDateStr =
              recordingDetails['recordingDate'] as String?;
          final locationDescription =
              recordingDetails['locationDescription'] as String?;

          String? city;
          String? country;

          if (lat != null && lng != null) {
            try {
              final placemarks =
                  await placemarkFromCoordinates(lat, lng);
              if (placemarks.isNotEmpty) {
                final placemark = placemarks.first;
                city = placemark.locality;
                country = placemark.country;
              }
            } catch (_) {
              // Fallback: try to parse locationDescription
              if (locationDescription != null &&
                  locationDescription.isNotEmpty) {
                final parts = locationDescription.split(',');
                if (parts.length >= 2) {
                  city = parts[0].trim();
                  country = parts[1].trim();
                } else {
                  city = locationDescription.trim();
                }
              }
            }
          }

          allVideos.add(VideoModel(
            id: item['id'] as String,
            title: snippet['title'] as String? ?? '',
            channelTitle: snippet['channelTitle'] as String? ?? '',
            thumbnailUrl: thumbnailUrl,
            publishedAt: snippet['publishedAt'] as String? ?? '',
            tags: tags,
            city: city,
            country: country,
            latitude: lat,
            longitude: lng,
            recordingDate: recordingDateStr,
          ));
        }
      }

      allVideos.sort((a, b) => b.publishedAt.compareTo(a.publishedAt));
      return allVideos;
    } on ServerException {
      rethrow;
    } catch (e) {
      throw ServerException('Failed to fetch videos: ${e.toString()}');
    }
  }
}
