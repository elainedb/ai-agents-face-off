import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:injectable/injectable.dart';
import 'package:geocoding/geocoding.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../config/config.dart';
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
        String? nextPageToken;
        final List<String> videoIds = [];
        
        do {
          var url = 'https://www.googleapis.com/youtube/v3/search?part=snippet&channelId=$channelId&type=video&order=date&maxResults=50&key=${Config.youtubeApiKey}';
          if (nextPageToken != null) {
            url += '&pageToken=$nextPageToken';
          }
          
          final response = await client.get(Uri.parse(url));
          if (response.statusCode != 200) {
            throw const ServerException();
          }
          
          final data = json.decode(response.body);
          nextPageToken = data['nextPageToken'];
          
          if (data['items'] != null) {
            for (var item in data['items']) {
              if (item['id'] != null && item['id']['videoId'] != null) {
                videoIds.add(item['id']['videoId']);
              }
            }
          }
        } while (nextPageToken != null);
        
        // Fetch details in batches of 50
        for (var i = 0; i < videoIds.length; i += 50) {
          final batch = videoIds.sublist(i, i + 50 > videoIds.length ? videoIds.length : i + 50);
          final idsString = batch.join(',');
          
          final detailsUrl = 'https://www.googleapis.com/youtube/v3/videos?part=snippet,recordingDetails&id=$idsString&key=${Config.youtubeApiKey}';
          final detailsResponse = await client.get(Uri.parse(detailsUrl));
          
          if (detailsResponse.statusCode != 200) {
            throw const ServerException();
          }
          
          final detailsData = json.decode(detailsResponse.body);
          
          if (detailsData['items'] != null) {
            for (var item in detailsData['items']) {
              final snippet = item['snippet'];
              final recordingDetails = item['recordingDetails'];
              
              double? latitude;
              double? longitude;
              String? recordingDate;
              String? city;
              String? country;
              
              if (recordingDetails != null) {
                if (recordingDetails['location'] != null) {
                  latitude = recordingDetails['location']['latitude']?.toDouble();
                  longitude = recordingDetails['location']['longitude']?.toDouble();
                }
                recordingDate = recordingDetails['recordingDate'];
                
                if (latitude != null && longitude != null) {
                  try {
                    final placemarks = await placemarkFromCoordinates(latitude, longitude);
                    if (placemarks.isNotEmpty) {
                      city = placemarks.first.locality;
                      country = placemarks.first.country;
                    }
                  } catch (_) {
                    // Fallback to locationDescription if geocoding fails
                    if (recordingDetails['locationDescription'] != null) {
                       final parts = recordingDetails['locationDescription'].toString().split(',');
                       if (parts.length > 1) {
                         city = parts[0].trim();
                         country = parts[1].trim();
                       } else {
                         city = parts[0].trim();
                       }
                    }
                  }
                } else if (recordingDetails['locationDescription'] != null) {
                  final parts = recordingDetails['locationDescription'].toString().split(',');
                  if (parts.length > 1) {
                    city = parts[0].trim();
                    country = parts[1].trim();
                  } else {
                    city = parts[0].trim();
                  }
                }
              }
              
              allVideos.add(VideoModel(
                id: item['id'],
                title: snippet['title'] ?? '',
                channelTitle: snippet['channelTitle'] ?? '',
                thumbnailUrl: snippet['thumbnails']?['high']?['url'] ?? snippet['thumbnails']?['default']?['url'] ?? '',
                publishedAt: snippet['publishedAt'] ?? DateTime.now().toIso8601String(),
                tags: List<String>.from(snippet['tags'] ?? []),
                city: city,
                country: country,
                latitude: latitude,
                longitude: longitude,
                recordingDate: recordingDate,
              ));
            }
          }
        }
      }
      
      allVideos.sort((a, b) => DateTime.parse(b.publishedAt).compareTo(DateTime.parse(a.publishedAt)));
      return allVideos;
    } catch (e) {
      throw const ServerException();
    }
  }
}