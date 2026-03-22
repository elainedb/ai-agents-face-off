import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:geocoding/geocoding.dart';
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
    final List<VideoModel> allVideos = [];

    for (final channelId in channelIds) {
      final videoIds = await _getVideoIdsFromChannel(channelId);
      if (videoIds.isNotEmpty) {
        final videos = await _getVideoDetails(videoIds);
        allVideos.addAll(videos);
      }
    }

    allVideos.sort((a, b) => b.publishedAt.compareTo(a.publishedAt));
    return allVideos;
  }

  Future<List<String>> _getVideoIdsFromChannel(String channelId) async {
    final List<String> videoIds = [];
    String? nextPageToken;

    do {
      final url = Uri.parse(
        'https://www.googleapis.com/youtube/v3/search'
        '?part=snippet'
        '&channelId=$channelId'
        '&type=video'
        '&order=date'
        '&maxResults=50'
        '&key=${Config.youtubeApiKey}'
        '${nextPageToken != null ? '&pageToken=$nextPageToken' : ''}',
      );

      final response = await client.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final items = data['items'] as List;
        for (final item in items) {
          videoIds.add(item['id']['videoId']);
        }
        nextPageToken = data['nextPageToken'];
      } else {
        throw ServerException('Failed to fetch videos from channel $channelId');
      }
    } while (nextPageToken != null);

    return videoIds;
  }

  Future<List<VideoModel>> _getVideoDetails(List<String> videoIds) async {
    final List<VideoModel> videoModels = [];

    // YouTube videos endpoint supports up to 50 IDs per request
    for (var i = 0; i < videoIds.length; i += 50) {
      final end = (i + 50 < videoIds.length) ? i + 50 : videoIds.length;
      final chunk = videoIds.sublist(i, end);
      final idsParam = chunk.join(',');

      final url = Uri.parse(
        'https://www.googleapis.com/youtube/v3/videos'
        '?part=snippet,recordingDetails'
        '&id=$idsParam'
        '&key=${Config.youtubeApiKey}',
      );

      final response = await client.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final items = data['items'] as List;
        for (final item in items) {
          final snippet = item['snippet'];
          final recordingDetails = item['recordingDetails'];
          
          double? latitude;
          double? longitude;
          String? recordingDate;
          String? city;
          String? country;

          if (recordingDetails != null) {
            final location = recordingDetails['location'];
            if (location != null) {
              latitude = location['latitude']?.toDouble();
              longitude = location['longitude']?.toDouble();
            }
            recordingDate = recordingDetails['recordingDate'];
          }

          if (latitude != null && longitude != null) {
            try {
              final placemarks = await placemarkFromCoordinates(latitude, longitude);
              if (placemarks.isNotEmpty) {
                final place = placemarks.first;
                city = place.locality;
                country = place.country;
              }
            } catch (_) {
              // Fallback to location description if geocoding fails
              final locationDescription = recordingDetails?['locationDescription'];
              if (locationDescription != null) {
                final parts = locationDescription.split(',');
                if (parts.length >= 2) {
                  city = parts[0].trim();
                  country = parts[parts.length - 1].trim();
                } else {
                  country = locationDescription.trim();
                }
              }
            }
          }

          videoModels.add(VideoModel(
            id: item['id'],
            title: snippet['title'],
            channelName: snippet['channelTitle'],
            thumbnailUrl: snippet['thumbnails']['high']['url'],
            publishedAt: snippet['publishedAt'],
            tags: snippet['tags'] != null ? List<String>.from(snippet['tags']) : [],
            city: city,
            country: country,
            latitude: latitude,
            longitude: longitude,
            recordingDate: recordingDate,
          ));
        }
      } else {
        throw ServerException('Failed to fetch video details');
      }
    }

    return videoModels;
  }
}
