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

  VideosRemoteDataSourceImpl({required this.client});

  @override
  Future<List<VideoModel>> getVideosFromChannels(List<String> channelIds) async {
    final List<VideoModel> allVideos = [];

    for (final channelId in channelIds) {
      final List<String> allVideoIds = [];
      String? nextPageToken;

      // Paginate through all videos for this channel
      do {
        final searchUrl = 'https://www.googleapis.com/youtube/v3/search'
            '?key=${Config.youtubeApiKey}'
            '&channelId=$channelId'
            '&part=snippet'
            '&order=date'
            '&type=video'
            '&maxResults=50'
            '${nextPageToken != null ? '&pageToken=$nextPageToken' : ''}';

        final searchResponse = await client.get(Uri.parse(searchUrl));

        if (searchResponse.statusCode == 200) {
          final Map<String, dynamic> searchData = json.decode(searchResponse.body);
          final List<dynamic> searchItems = searchData['items'] ?? [];

          // Extract video IDs from this page
          final pageVideoIds = searchItems
              .map((item) => item['id']['videoId'] as String)
              .toList();

          allVideoIds.addAll(pageVideoIds);

          // Check if there's a next page
          nextPageToken = searchData['nextPageToken'] as String?;
        } else {
          throw ServerException('Failed to load videos for channel: $channelId');
        }
      } while (nextPageToken != null);

      if (allVideoIds.isEmpty) continue;

      // Process videos in batches of 50 (YouTube API limit)
      for (int i = 0; i < allVideoIds.length; i += 50) {
        final batch = allVideoIds.skip(i).take(50);
        final videoIds = batch.join(',');

        // Get detailed video information including tags and location
        final videosUrl = 'https://www.googleapis.com/youtube/v3/videos'
            '?key=${Config.youtubeApiKey}'
            '&id=$videoIds'
            '&part=snippet,recordingDetails';

        final videosResponse = await client.get(Uri.parse(videosUrl));

        if (videosResponse.statusCode == 200) {
          final Map<String, dynamic> videosData = json.decode(videosResponse.body);
          final List<dynamic> videoItems = videosData['items'] ?? [];

          for (final videoItem in videoItems) {
            final snippet = videoItem['snippet'];
            final recordingDetails = videoItem['recordingDetails'];

            // Extract tags
            final tags = (snippet['tags'] as List<dynamic>?)
                ?.cast<String>() ?? <String>[];

            // Extract location information
            String? city;
            String? country;
            double? latitude;
            double? longitude;

            if (recordingDetails != null) {
              final location = recordingDetails['location'];
              if (location != null) {
                latitude = location['latitude']?.toDouble();
                longitude = location['longitude']?.toDouble();
              }

              final locationDescription = recordingDetails['locationDescription'];
              if (locationDescription != null) {
                // Parse location description (usually in format "City, Country")
                final locationParts = locationDescription.split(',');
                if (locationParts.length >= 2) {
                  city = locationParts[0].trim();
                  country = locationParts[1].trim();
                } else if (locationParts.length == 1) {
                  country = locationParts[0].trim();
                }
              }

              // ALWAYS do reverse geocoding if we have coordinates, regardless of locationDescription
              if (latitude != null && longitude != null) {
                try {
                  final placemarks = await placemarkFromCoordinates(latitude, longitude);
                  if (placemarks.isNotEmpty) {
                    final placemark = placemarks.first;
                    // Override with reverse geocoding data (more accurate)
                    city = placemark.locality ?? placemark.subAdministrativeArea ?? city;
                    country = placemark.country ?? country;
                  }
                } catch (e) {
                  // Ignore geocoding errors and continue without location
                  // Keep any existing location data from locationDescription
                }
              }
            }

            // Extract recording date
            final recordingDate = recordingDetails?['recordingDate'] as String?;

            final videoModel = VideoModel(
              id: videoItem['id'],
              title: snippet['title'],
              channelTitle: snippet['channelTitle'],
              thumbnailUrl: snippet['thumbnails']['medium']['url'],
              publishedAt: snippet['publishedAt'],
              tags: tags,
              city: city,
              country: country,
              latitude: latitude,
              longitude: longitude,
              recordingDate: recordingDate,
            );
            allVideos.add(videoModel);
          }
        } else {
          // If videos endpoint fails, create basic models from the video IDs
          for (final videoId in batch) {
            final videoModel = VideoModel(
              id: videoId,
              title: 'Video $videoId', // Placeholder title
              channelTitle: 'Unknown Channel', // Placeholder
              thumbnailUrl: '', // No thumbnail available
              publishedAt: DateTime.now().toIso8601String(), // Placeholder date
            );
            allVideos.add(videoModel);
          }
        }
      }
    }

    // Sort by published date (newest first)
    allVideos.sort((a, b) =>
        DateTime.parse(b.publishedAt).compareTo(DateTime.parse(a.publishedAt)));

    return allVideos;
  }
}