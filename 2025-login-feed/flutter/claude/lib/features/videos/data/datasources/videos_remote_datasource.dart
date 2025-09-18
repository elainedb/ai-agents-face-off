import 'dart:convert';
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

  VideosRemoteDataSourceImpl({required this.client});

  @override
  Future<List<VideoModel>> getVideosFromChannels(List<String> channelIds) async {
    final List<VideoModel> allVideos = [];

    for (final channelId in channelIds) {
      final url = 'https://www.googleapis.com/youtube/v3/search'
          '?key=${Config.youtubeApiKey}'
          '&channelId=$channelId'
          '&part=snippet'
          '&order=date'
          '&type=video'
          '&maxResults=10';

      final response = await client.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        final List<dynamic> items = data['items'] ?? [];

        for (final item in items) {
          final snippet = item['snippet'];
          final videoModel = VideoModel(
            id: item['id']['videoId'],
            title: snippet['title'],
            channelTitle: snippet['channelTitle'],
            thumbnailUrl: snippet['thumbnails']['medium']['url'],
            publishedAt: snippet['publishedAt'],
          );
          allVideos.add(videoModel);
        }
      } else {
        throw ServerException('Failed to load videos for channel: $channelId');
      }
    }

    // Sort by published date (newest first)
    allVideos.sort((a, b) =>
        DateTime.parse(b.publishedAt).compareTo(DateTime.parse(a.publishedAt)));

    return allVideos;
  }
}