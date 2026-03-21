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

      // Step 1: Search for videos in each channel
      for (final channelId in channelIds) {
        String? pageToken;
        do {
          final queryParams = <String, String>{
            'part': 'snippet',
            'channelId': channelId,
            'type': 'video',
            'order': 'date',
            'maxResults': '50',
            'key': Config.youtubeApiKey,
            if (pageToken != null) 'pageToken': pageToken,
          };

          final uri = Uri.https(
            'www.googleapis.com',
            '/youtube/v3/search',
            queryParams,
          );

          final response = await client.get(uri);
          if (response.statusCode != 200) {
            throw ServerException(
                'YouTube API search failed: ${response.statusCode}');
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

      // Step 2: Fetch detailed video info in batches of 50
      final allModels = <VideoModel>[];
      for (var i = 0; i < allVideoIds.length; i += 50) {
        final batch = allVideoIds.skip(i).take(50).toList();
        final uri = Uri.https(
          'www.googleapis.com',
          '/youtube/v3/videos',
          {
            'part': 'snippet,recordingDetails',
            'id': batch.join(','),
            'key': Config.youtubeApiKey,
          },
        );

        final response = await client.get(uri);
        if (response.statusCode != 200) {
          throw ServerException(
              'YouTube API videos failed: ${response.statusCode}');
        }

        final data = json.decode(response.body) as Map<String, dynamic>;
        final items = data['items'] as List<dynamic>? ?? [];

        for (final item in items) {
          final snippet = item['snippet'] as Map<String, dynamic>? ?? {};
          final recordingDetails =
              item['recordingDetails'] as Map<String, dynamic>? ?? {};

          final videoId = item['id'] as String;
          final title = snippet['title'] as String? ?? '';
          final channelTitle = snippet['channelTitle'] as String? ?? '';
          final publishedAt = snippet['publishedAt'] as String? ?? '';
          final tags =
              (snippet['tags'] as List<dynamic>?)?.cast<String>() ?? [];

          final thumbnails =
              snippet['thumbnails'] as Map<String, dynamic>? ?? {};
          final high = thumbnails['high'] as Map<String, dynamic>? ?? {};
          final thumbnailUrl = high['url'] as String? ??
              (thumbnails['default'] as Map<String, dynamic>?)?['url'] as String? ??
              '';

          final location =
              recordingDetails['location'] as Map<String, dynamic>?;
          final lat = location?['latitude'] as double?;
          final lng = location?['longitude'] as double?;
          final recordingDate =
              recordingDetails['recordingDate'] as String?;
          final locationDescription =
              recordingDetails['locationDescription'] as String?;

          String? city;
          String? country;

          // Step 3: Reverse geocoding for videos with coordinates
          if (lat != null && lng != null) {
            try {
              final placemarks =
                  await placemarkFromCoordinates(lat, lng);
              if (placemarks.isNotEmpty) {
                city = placemarks.first.locality;
                country = placemarks.first.country;
              }
            } catch (_) {
              // Fall back to locationDescription
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

          allModels.add(VideoModel(
            id: videoId,
            title: title,
            channelTitle: channelTitle,
            thumbnailUrl: thumbnailUrl,
            publishedAt: publishedAt,
            tags: tags,
            city: city,
            country: country,
            latitude: lat,
            longitude: lng,
            recordingDate: recordingDate,
          ));
        }
      }

      // Sort by publishedAt descending
      allModels.sort((a, b) => b.publishedAt.compareTo(a.publishedAt));

      return allModels;
    } on ServerException {
      rethrow;
    } catch (e) {
      throw ServerException('Failed to fetch videos: $e');
    }
  }
}
