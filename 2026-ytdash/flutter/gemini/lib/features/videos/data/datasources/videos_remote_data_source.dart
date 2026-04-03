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
    try {
      final List<VideoModel> allVideos = [];

      for (final channelId in channelIds) {
        String? pageToken;
        final List<String> videoIds = [];

        do {
          var url = 'https://www.googleapis.com/youtube/v3/search?part=snippet&channelId=$channelId&type=video&order=date&maxResults=50&key=${Config.youtubeApiKey}';
          if (pageToken != null) {
            url += '&pageToken=$pageToken';
          }

          final response = await client.get(Uri.parse(url));

          if (response.statusCode == 200) {
            final data = json.decode(response.body);
            final items = data['items'] as List;

            for (final item in items) {
              final id = item['id']['videoId'] as String?;
              if (id != null) {
                videoIds.add(id);
              }
            }

            pageToken = data['nextPageToken'];
          } else {
            throw ServerException('Failed to search videos for channel $channelId');
          }
        } while (pageToken != null);

        // Fetch detailed info in batches of 50
        for (var i = 0; i < videoIds.length; i += 50) {
          final batchIds = videoIds.sublist(i, i + 50 > videoIds.length ? videoIds.length : i + 50);
          final idsStr = batchIds.join(',');

          final videosUrl = 'https://www.googleapis.com/youtube/v3/videos?part=snippet,recordingDetails&id=$idsStr&key=${Config.youtubeApiKey}';
          final videosResponse = await client.get(Uri.parse(videosUrl));

          if (videosResponse.statusCode == 200) {
            final data = json.decode(videosResponse.body);
            final items = data['items'] as List;

            for (final item in items) {
              final snippet = item['snippet'];
              final recordingDetails = item['recordingDetails'];
              final location = recordingDetails?['location'];

              double? latitude;
              double? longitude;
              String? city;
              String? country;

              if (location != null) {
                latitude = location['latitude']?.toDouble();
                longitude = location['longitude']?.toDouble();

                if (latitude != null && longitude != null) {
                  try {
                    List<Placemark> placemarks = await placemarkFromCoordinates(latitude, longitude);
                    if (placemarks.isNotEmpty) {
                      city = placemarks.first.locality ?? placemarks.first.subAdministrativeArea;
                      country = placemarks.first.country;
                    }
                  } catch (_) {
                    // Ignore geocoding errors, fallback to description
                    final locationDescription = location['locationDescription'] as String?;
                    if (locationDescription != null) {
                      city = locationDescription;
                    }
                  }
                } else {
                  final locationDescription = location['locationDescription'] as String?;
                  if (locationDescription != null) {
                    city = locationDescription;
                  }
                }
              }

              final thumbnail = snippet['thumbnails']['high']?['url'] ?? snippet['thumbnails']['default']?['url'] ?? '';
              
              List<String> tags = [];
              if (snippet['tags'] != null) {
                 tags = List<String>.from(snippet['tags']);
              }

              final videoModel = VideoModel(
                id: item['id'],
                title: snippet['title'],
                channelTitle: snippet['channelTitle'],
                thumbnailUrl: thumbnail,
                publishedAt: snippet['publishedAt'],
                tags: tags,
                city: city,
                country: country,
                latitude: latitude,
                longitude: longitude,
                recordingDate: recordingDetails?['recordingDate'],
              );

              allVideos.add(videoModel);
            }
          } else {
             throw ServerException('Failed to fetch detailed info for videos');
          }
        }
      }

      allVideos.sort((a, b) => b.publishedAt.compareTo(a.publishedAt));
      return allVideos;
    } catch (e) {
      if (e is ServerException) rethrow;
      throw ServerException(e.toString());
    }
  }
}
