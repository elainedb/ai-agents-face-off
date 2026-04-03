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
  final http.Client client;

  VideosRemoteDataSourceImpl(this.client);

  @override
  Future<List<VideoModel>> getVideosFromChannels(List<String> channelIds) async {
    final List<String> allVideoIds = [];
    
    // 1 & 2: Get all video IDs from search endpoint
    for (final channelId in channelIds) {
      String? pageToken;
      do {
        final queryParams = <String, dynamic>{
          'part': 'snippet',
          'channelId': channelId,
          'type': 'video',
          'order': 'date',
          'maxResults': '50',
          'key': Config.youtubeApiKey,
        };
        if (pageToken != null) {
          queryParams['pageToken'] = pageToken;
        }
        
        final uri = Uri.parse('https://www.googleapis.com/youtube/v3/search').replace(queryParameters: queryParams);

        final response = await client.get(uri);
        if (response.statusCode != 200) {
          throw ServerException('Failed to fetch videos from YouTube Search API');
        }

        final data = json.decode(response.body);
        final items = data['items'] as List;
        for (final item in items) {
          allVideoIds.add(item['id']['videoId'] as String);
        }
        
        pageToken = data['nextPageToken'];
      } while (pageToken != null);
    }

    if (allVideoIds.isEmpty) return [];

    // 3: Get detailed info in batches (max 50 per request)
    final List<VideoModel> videos = [];
    for (int i = 0; i < allVideoIds.length; i += 50) {
      final batchIds = allVideoIds.skip(i).take(50).join(',');
      final uri = Uri.parse('https://www.googleapis.com/youtube/v3/videos').replace(queryParameters: {
        'part': 'snippet,recordingDetails',
        'id': batchIds,
        'key': Config.youtubeApiKey,
      });

      final response = await client.get(uri);
      if (response.statusCode != 200) {
        throw ServerException('Failed to fetch detailed video info from YouTube API');
      }

      final data = json.decode(response.body);
      final items = data['items'] as List;

      for (final item in items) {
        final snippet = item['snippet'];
        final recordingDetails = item['recordingDetails'];

        String? city;
        String? country;
        double? latitude;
        double? longitude;
        String? recordingDate;

        if (recordingDetails != null) {
          recordingDate = recordingDetails['recordingDate'];
          final location = recordingDetails['location'];
          if (location != null) {
            latitude = location['latitude'] as double?;
            longitude = location['longitude'] as double?;
          }
          
          if (latitude != null && longitude != null) {
            try {
              final placemarks = await placemarkFromCoordinates(latitude, longitude);
              if (placemarks.isNotEmpty) {
                final place = placemarks.first;
                city = place.locality ?? place.subAdministrativeArea ?? place.administrativeArea;
                country = place.country;
              }
            } catch (e) {
              // Geocoding failed, fallback to locationDescription if available
              final locationDescription = recordingDetails['locationDescription'] as String?;
              if (locationDescription != null) {
                final parts = locationDescription.split(',');
                if (parts.length >= 2) {
                  city = parts[0].trim();
                  country = parts[1].trim();
                } else {
                  city = locationDescription;
                }
              }
            }
          }
        }

        List<String> tags = [];
        if (snippet['tags'] != null) {
          tags = List<String>.from(snippet['tags']);
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
    }

    // 6: Sort by publishedAt descending
    videos.sort((a, b) => DateTime.parse(b.publishedAt).compareTo(DateTime.parse(a.publishedAt)));

    return videos;
  }
}
