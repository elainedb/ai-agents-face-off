import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:injectable/injectable.dart';
import 'package:geocoding/geocoding.dart';
import 'package:ytdash_flutter_gemini/config/config.dart';
import 'package:ytdash_flutter_gemini/core/error/exceptions.dart';
import 'package:ytdash_flutter_gemini/features/videos/data/models/video_model.dart';

abstract class VideosRemoteDataSource {
  Future<List<VideoModel>> getVideosFromChannels(List<String> channelIds);
}

@LazySingleton(as: VideosRemoteDataSource)
class VideosRemoteDataSourceImpl implements VideosRemoteDataSource {
  final http.Client client;

  VideosRemoteDataSourceImpl({required this.client});

  @override
  Future<List<VideoModel>> getVideosFromChannels(List<String> channelIds) async {
    final List<String> allVideoIds = [];
    final String apiKey = Config.youtubeApiKey;

    // 1. For each channel ID, call YouTube Data API search endpoint
    for (final channelId in channelIds) {
      String? nextPageToken;
      do {
        var url = 'https://www.googleapis.com/youtube/v3/search?part=snippet&channelId=$channelId&type=video&order=date&maxResults=50&key=$apiKey';
        if (nextPageToken != null) {
          url += '&pageToken=$nextPageToken';
        }

        final response = await client.get(Uri.parse(url));

        if (response.statusCode != 200) {
          throw ServerException('Failed to fetch search results from YouTube API');
        }

        final data = json.decode(response.body);
        final items = data['items'] as List;
        for (var item in items) {
          allVideoIds.add(item['id']['videoId']);
        }

        nextPageToken = data['nextPageToken'];
      } while (nextPageToken != null);
    }

    // 2. Batched fetch of detailed info
    final List<VideoModel> allVideos = [];
    for (var i = 0; i < allVideoIds.length; i += 50) {
      final end = (i + 50 < allVideoIds.length) ? i + 50 : allVideoIds.length;
      final batchIds = allVideoIds.sublist(i, end);
      final idsString = batchIds.join(',');

      final videosUrl = 'https://www.googleapis.com/youtube/v3/videos?part=snippet,recordingDetails&id=$idsString&key=$apiKey';
      final response = await client.get(Uri.parse(videosUrl));

      if (response.statusCode != 200) {
        throw ServerException('Failed to fetch detailed video data');
      }

      final data = json.decode(response.body);
      final items = data['items'] as List;

      for (var item in items) {
        final snippet = item['snippet'];
        final recordingDetails = item['recordingDetails'];

        final id = item['id'];
        final title = snippet['title'];
        final channelTitle = snippet['channelTitle'];
        final thumbnailUrl = snippet['thumbnails']['high']?['url'] ?? snippet['thumbnails']['default']?['url'];
        final publishedAt = snippet['publishedAt'];
        final tags = List<String>.from(snippet['tags'] ?? []);

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
              try {
                final placemarks = await placemarkFromCoordinates(latitude, longitude);
                if (placemarks.isNotEmpty) {
                  city = placemarks.first.locality ?? placemarks.first.subAdministrativeArea;
                  country = placemarks.first.country;
                }
              } catch (e) {
                // Ignore geocoding errors
              }
            }
            if (city == null && country == null && recordingDetails['locationDescription'] != null) {
               // Fallback
               final parts = recordingDetails['locationDescription'].split(',');
               if (parts.length >= 2) {
                 city = parts[0].trim();
                 country = parts[1].trim();
               } else {
                 city = recordingDetails['locationDescription'];
               }
            }
          }
        }

        allVideos.add(VideoModel(
          id: id,
          title: title,
          channelTitle: channelTitle,
          thumbnailUrl: thumbnailUrl,
          publishedAt: publishedAt,
          tags: tags,
          city: city,
          country: country,
          latitude: latitude,
          longitude: longitude,
          recordingDate: recordingDate,
        ));
      }
    }

    allVideos.sort((a, b) => DateTime.parse(b.publishedAt).compareTo(DateTime.parse(a.publishedAt)));
    return allVideos;
  }
}
