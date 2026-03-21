import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:injectable/injectable.dart';
import 'package:geocoding/geocoding.dart';

import '../../../../config/config.dart';
import '../../../../core/error/exceptions.dart';
import '../models/video_model.dart';

abstract class VideosRemoteDataSource {
  Future<List<VideoModel>> getVideosFromChannels(List<String> channelIds);
}

@LazySingleton(as: VideosRemoteDataSource)
class VideosRemoteDataSourceImpl implements VideosRemoteDataSource {
  final http.Client client;

  VideosRemoteDataSourceImpl(this.client);

  @override
  Future<List<VideoModel>> getVideosFromChannels(List<String> channelIds) async {
    final List<String> videoIds = [];
    final List<VideoModel> videos = [];

    // 1. & 2. Fetch search results per channel and collect video IDs
    for (final channelId in channelIds) {
      String? pageToken;
      do {
        final uri = Uri.parse('https://www.googleapis.com/youtube/v3/search').replace(queryParameters: {
          'part': 'snippet',
          'channelId': channelId,
          'type': 'video',
          'order': 'date',
          'maxResults': '50',
          'key': Config.youtubeApiKey,
          if (pageToken != null) 'pageToken': pageToken,
        });

        final response = await client.get(uri);

        if (response.statusCode == 200) {
          final data = json.decode(response.body);
          final items = data['items'] as List;
          for (final item in items) {
            final videoId = item['id']['videoId'];
            if (videoId != null) {
              videoIds.add(videoId);
            }
          }
          pageToken = data['nextPageToken'];
        } else {
          throw ServerException('Failed to search videos: ${response.statusCode}');
        }
      } while (pageToken != null);
    }

    if (videoIds.isEmpty) return [];

    // 3. Fetch detailed video data in batches of 50
    const batchSize = 50;
    for (var i = 0; i < videoIds.length; i += batchSize) {
      final batchIds = videoIds.skip(i).take(batchSize).join(',');

      final uri = Uri.parse('https://www.googleapis.com/youtube/v3/videos').replace(queryParameters: {
        'part': 'snippet,recordingDetails',
        'id': batchIds,
        'key': Config.youtubeApiKey,
      });

      final response = await client.get(uri);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final items = data['items'] as List;

        for (final item in items) {
          final snippet = item['snippet'];
          final recordingDetails = item['recordingDetails'];
          
          final tags = (snippet['tags'] as List?)?.map((e) => e as String).toList() ?? [];
          
          String? city;
          String? country;
          double? latitude;
          double? longitude;
          String? recordingDate;

          if (recordingDetails != null) {
            recordingDate = recordingDetails['recordingDate'];
            final location = recordingDetails['location'];
            if (location != null) {
              latitude = location['latitude']?.toDouble();
              longitude = location['longitude']?.toDouble();
              
              if (latitude != null && longitude != null) {
                // 5. Reverse geocoding
                try {
                  final placemarks = await placemarkFromCoordinates(latitude, longitude);
                  if (placemarks.isNotEmpty) {
                    final place = placemarks.first;
                    city = place.locality ?? place.subAdministrativeArea;
                    country = place.country;
                  }
                } catch (_) {
                  // Fallback to locationDescription if geocoding fails
                  final locationDescription = recordingDetails['locationDescription'];
                  if (locationDescription != null) {
                    final parts = locationDescription.toString().split(',');
                    if (parts.length > 1) {
                      city = parts[0].trim();
                      country = parts[1].trim();
                    } else if (parts.isNotEmpty) {
                      city = parts[0].trim();
                    }
                  }
                }
              }
            }
          }

          videos.add(VideoModel(
            id: item['id'],
            title: snippet['title'],
            channelTitle: snippet['channelTitle'],
            thumbnailUrl: snippet['thumbnails']['high']?['url'] ?? snippet['thumbnails']['default']?['url'] ?? '',
            publishedAt: snippet['publishedAt'],
            tags: tags,
            city: city,
            country: country,
            latitude: latitude,
            longitude: longitude,
            recordingDate: recordingDate,
          ));
        }
      } else {
        throw ServerException('Failed to fetch videos details: ${response.statusCode}');
      }
    }

    // 6. Sort by publishedAt descending
    videos.sort((a, b) => DateTime.parse(b.publishedAt).compareTo(DateTime.parse(a.publishedAt)));
    return videos;
  }
}
