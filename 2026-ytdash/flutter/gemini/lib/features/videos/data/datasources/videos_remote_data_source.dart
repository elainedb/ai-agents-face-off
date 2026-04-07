import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:injectable/injectable.dart';
import '../../../../config/config.dart';
import '../../../../core/error/exceptions.dart';
import '../models/video_model.dart';
import '../services/geocoding_service.dart';

abstract class VideosRemoteDataSource {
  Future<List<VideoModel>> getVideosFromChannels(List<String> channelIds);
}

@LazySingleton(as: VideosRemoteDataSource)
class VideosRemoteDataSourceImpl implements VideosRemoteDataSource {
  final http.Client client;
  final GeocodingService geocodingService;

  VideosRemoteDataSourceImpl({required this.client, required this.geocodingService});

  @override
  Future<List<VideoModel>> getVideosFromChannels(List<String> channelIds) async {
    final futures = channelIds.map((id) => _fetchVideosForChannel(id));
    final results = await Future.wait(futures);
    final allVideos = results.expand((i) => i).toList();
    allVideos.sort((a, b) => b.publishedAt.compareTo(a.publishedAt));
    return allVideos;
  }

  Future<List<VideoModel>> _fetchVideosForChannel(String channelId) async {
    List<String> videoIds = [];
    String? nextPageToken;

    do {
      var url = 'https://www.googleapis.com/youtube/v3/search?part=snippet&channelId=$channelId&type=video&order=date&maxResults=50&key=${Config.youtubeApiKey}';
      if (nextPageToken != null) {
        url += '&pageToken=$nextPageToken';
      }

      final response = await client.get(Uri.parse(url));
      if (response.statusCode != 200) {
        throw ServerException('Failed to fetch videos for channel $channelId');
      }

      final data = json.decode(response.body);
      final items = data['items'] as List;
      for (var item in items) {
        videoIds.add(item['id']['videoId']);
      }
      
      nextPageToken = data['nextPageToken'];
    } while (nextPageToken != null);

    List<VideoModel> channelVideos = [];
    for (int i = 0; i < videoIds.length; i += 50) {
      final end = (i + 50 < videoIds.length) ? i + 50 : videoIds.length;
      final batchIds = videoIds.sublist(i, end).join(',');
      
      final url = 'https://www.googleapis.com/youtube/v3/videos?part=snippet,recordingDetails&id=$batchIds&key=${Config.youtubeApiKey}';
      final response = await client.get(Uri.parse(url));
      
      if (response.statusCode != 200) {
        throw ServerException('Failed to fetch video details');
      }

      final data = json.decode(response.body);
      final items = data['items'] as List;

      for (var item in items) {
        final snippet = item['snippet'];
        final recordingDetails = item['recordingDetails'];
        
        final id = item['id'];
        final title = snippet['title'];
        final channelTitle = snippet['channelTitle'];
        final thumbnailUrl = snippet['thumbnails']['high']?['url'] ?? snippet['thumbnails']['default']?['url'] ?? '';
        final publishedAt = snippet['publishedAt'];
        final tags = List<String>.from(snippet['tags'] ?? []);
        
        double? lat;
        double? lon;
        String? recordingDate;
        String? locationDescription;

        if (recordingDetails != null) {
          if (recordingDetails['location'] != null) {
            lat = recordingDetails['location']['latitude']?.toDouble();
            lon = recordingDetails['location']['longitude']?.toDouble();
          }
          recordingDate = recordingDetails['recordingDate'];
          locationDescription = recordingDetails['locationDescription'];
        }

        String? city;
        String? country;

        if (lat != null && lon != null) {
          final loc = await geocodingService.getCityAndCountry(lat, lon, locationDescription: locationDescription);
          city = loc.$1;
          country = loc.$2;
        }

        channelVideos.add(VideoModel(
          id: id,
          title: title,
          channelTitle: channelTitle,
          thumbnailUrl: thumbnailUrl,
          publishedAt: publishedAt,
          tags: tags,
          city: city,
          country: country,
          latitude: lat,
          longitude: lon,
          recordingDate: recordingDate,
        ));
      }
    }

    return channelVideos;
  }
}
