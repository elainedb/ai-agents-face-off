import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:injectable/injectable.dart';
import '../../../../config/config.dart';
import '../../../../core/error/exceptions.dart';
import '../models/video_model.dart';
import 'geocoding_service.dart';

@lazySingleton
class VideosRemoteDataSource {
  final http.Client client;
  final GeocodingService geocodingService;

  VideosRemoteDataSource(this.client, this.geocodingService);

  Future<List<VideoModel>> getVideosFromChannels(List<String> channelIds) async {
    final futures = channelIds.map((id) => _fetchVideosForChannel(id));
    final results = await Future.wait(futures);
    
    final allVideos = results.expand((x) => x).toList();
    allVideos.sort((a, b) => DateTime.parse(b.publishedAt).compareTo(DateTime.parse(a.publishedAt)));
    return allVideos;
  }

  Future<List<VideoModel>> _fetchVideosForChannel(String channelId) async {
    List<String> videoIds = [];
    String? pageToken;

    // Search API for all video IDs from the channel
    do {
      var urlStr = 'https://www.googleapis.com/youtube/v3/search?part=snippet&channelId=$channelId&type=video&order=date&maxResults=50&key=${Config.youtubeApiKey}';
      if (pageToken != null && pageToken.isNotEmpty) {
        urlStr += '&pageToken=$pageToken';
      }

      final response = await client.get(Uri.parse(urlStr));
      if (response.statusCode != 200) {
        throw const ServerException('Failed to fetch videos from YouTube search API.');
      }

      final data = json.decode(response.body);
      final items = data['items'] as List;
      videoIds.addAll(items.map((e) => e['id']['videoId'] as String));
      
      pageToken = data['nextPageToken'];
    } while (pageToken != null);

    // Videos API for full metadata
    List<VideoModel> videos = [];
    
    for (int i = 0; i < videoIds.length; i += 50) {
      final batch = videoIds.sublist(i, i + 50 > videoIds.length ? videoIds.length : i + 50);
      final idsParam = batch.join(',');
      
      final urlStr = 'https://www.googleapis.com/youtube/v3/videos?part=snippet,recordingDetails&id=$idsParam&key=${Config.youtubeApiKey}';
      final response = await client.get(Uri.parse(urlStr));
      
      if (response.statusCode != 200) {
        throw const ServerException('Failed to fetch video details.');
      }
      
      final data = json.decode(response.body);
      final items = data['items'] as List;
      
      for (var item in items) {
        final snippet = item['snippet'];
        final recordingDetails = item['recordingDetails'];
        
        double? lat;
        double? lon;
        String? recordingDate;
        String? city;
        String? country;
        
        if (recordingDetails != null) {
          if (recordingDetails['location'] != null) {
            lat = recordingDetails['location']['latitude']?.toDouble();
            lon = recordingDetails['location']['longitude']?.toDouble();
          }
          recordingDate = recordingDetails['recordingDate'];
          
          if (recordingDetails['locationDescription'] != null) {
            final loc = geocodingService.parseLocationFromDescription(recordingDetails['locationDescription']);
            city = loc.$1;
            country = loc.$2;
          }
        }
        
        if (lat != null && lon != null && (city == null || country == null)) {
           final geo = await geocodingService.getCityAndCountry(lat, lon);
           city ??= geo.$1;
           country ??= geo.$2;
        }

        videos.add(VideoModel(
          id: item['id'],
          title: snippet['title'],
          channelTitle: snippet['channelTitle'],
          thumbnailUrl: snippet['thumbnails']['high']?['url'] ?? snippet['thumbnails']['default']['url'],
          publishedAt: snippet['publishedAt'],
          tags: snippet['tags'] != null ? List<String>.from(snippet['tags']) : [],
          city: city,
          country: country,
          latitude: lat,
          longitude: lon,
          recordingDate: recordingDate,
        ));
      }
    }

    return videos;
  }
}
