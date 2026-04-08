import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:injectable/injectable.dart';
import '../../../../config/config.dart';
import '../../../../core/error/exceptions.dart';
import '../models/video_model.dart';
import 'geocoding_service.dart';

abstract class VideosRemoteDataSource {
  Future<List<VideoModel>> getVideosFromChannels(List<String> channelIds);
}

@LazySingleton(as: VideosRemoteDataSource)
class VideosRemoteDataSourceImpl implements VideosRemoteDataSource {
  final http.Client httpClient;
  final GeocodingService geocodingService;

  VideosRemoteDataSourceImpl({
    required this.httpClient,
    required this.geocodingService,
  });

  @override
  Future<List<VideoModel>> getVideosFromChannels(List<String> channelIds) async {
    try {
      final futures = channelIds.map((id) => _fetchVideosForChannel(id));
      final results = await Future.wait(futures);
      
      final allVideos = results.expand((x) => x).toList();
      allVideos.sort((a, b) => b.publishedAt.compareTo(a.publishedAt));
      
      return allVideos;
    } catch (e) {
      if (e is ServerException) rethrow;
      throw ServerException(e.toString());
    }
  }

  Future<List<VideoModel>> _fetchVideosForChannel(String channelId) async {
    String? pageToken;
    final List<String> videoIds = [];

    // 1. Fetch all video IDs using exhaustive pagination
    do {
      var url = 'https://www.googleapis.com/youtube/v3/search?part=snippet&channelId=$channelId&type=video&order=date&maxResults=50&key=${Config.youtubeApiKey}';
      if (pageToken != null) {
        url += '&pageToken=$pageToken';
      }

      final response = await httpClient.get(Uri.parse(url));
      if (response.statusCode != 200) {
        throw ServerException('Failed to fetch videos from channel $channelId');
      }

      final data = jsonDecode(response.body);
      final items = data['items'] as List<dynamic>;
      
      for (final item in items) {
        final id = item['id']['videoId'] as String?;
        if (id != null) {
          videoIds.add(id);
        }
      }

      pageToken = data['nextPageToken'] as String?;
    } while (pageToken != null);

    // 2. Fetch detailed info in batches of 50
    final List<VideoModel> channelVideos = [];
    for (var i = 0; i < videoIds.length; i += 50) {
      final batchIds = videoIds.sublist(i, i + 50 > videoIds.length ? videoIds.length : i + 50);
      final detailedVideos = await _fetchVideoDetails(batchIds.join(','));
      channelVideos.addAll(detailedVideos);
    }

    return channelVideos;
  }

  Future<List<VideoModel>> _fetchVideoDetails(String idsCommaSeparated) async {
    final url = 'https://www.googleapis.com/youtube/v3/videos?part=snippet,recordingDetails&id=$idsCommaSeparated&key=${Config.youtubeApiKey}';
    final response = await httpClient.get(Uri.parse(url));

    if (response.statusCode != 200) {
      throw const ServerException('Failed to fetch video details');
    }

    final data = jsonDecode(response.body);
    final items = data['items'] as List<dynamic>;
    
    final List<VideoModel> videos = [];

    // Process geocoding sequentially or limited concurrency
    for (final item in items) {
      final snippet = item['snippet'];
      final recordingDetails = item['recordingDetails'];
      
      double? lat;
      double? lng;
      String? locationDesc;
      
      if (recordingDetails != null && recordingDetails['location'] != null) {
        lat = recordingDetails['location']['latitude'] as double?;
        lng = recordingDetails['location']['longitude'] as double?;
        locationDesc = recordingDetails['locationDescription'] as String?;
      }

      String? city;
      String? country;

      if (lat != null && lng != null) {
        final geocoded = await geocodingService.reverseGeocode(
          lat, 
          lng, 
          locationDescriptionFallback: locationDesc
        );
        city = geocoded.$1;
        country = geocoded.$2;
      } else if (locationDesc != null) {
        final parts = locationDesc.split(',');
        if (parts.length >= 2) {
          city = parts[0].trim();
          country = parts[1].trim();
        } else {
          city = locationDesc.trim();
        }
      }

      final tags = snippet['tags'] as List<dynamic>?;

      videos.add(VideoModel(
        id: item['id'] as String,
        title: snippet['title'] as String,
        channelTitle: snippet['channelTitle'] as String,
        thumbnailUrl: snippet['thumbnails']?['high']?['url'] ?? snippet['thumbnails']?['default']?['url'] ?? '',
        publishedAt: snippet['publishedAt'] as String,
        tags: tags?.map((e) => e.toString()).toList() ?? [],
        city: city,
        country: country,
        latitude: lat,
        longitude: lng,
        recordingDate: recordingDetails?['recordingDate'] as String?,
      ));
    }

    return videos;
  }
}
