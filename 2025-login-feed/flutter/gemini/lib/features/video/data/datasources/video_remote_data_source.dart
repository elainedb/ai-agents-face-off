import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:flutter_gemini/features/video/data/models/video_model.dart';
import 'package:http/http.dart' as http;
import 'package:injectable/injectable.dart';

abstract class VideoRemoteDataSource {
  Future<List<VideoModel>> getVideos();
}

@LazySingleton(as: VideoRemoteDataSource)
class VideoRemoteDataSourceImpl implements VideoRemoteDataSource {
  final http.Client client;

  VideoRemoteDataSourceImpl(this.client);

  final _channelIds = [
    'UCynoa1DjwnvHAowA_jiMEAQ',
    'UCK0KOjX3beyB9nzonls0cuw',
    'UCACkIrvrGAQ7kuc0hMVwvmA',
    'UCtWRAKKvOEA0CXOue9BG8ZA',
  ];

  Future<String> _getApiKey() async {
    try {
      return await rootBundle.loadString('assets/api_key_local.txt');
    } catch (e) {
      return await rootBundle.loadString('assets/api_key.txt');
    }
  }

  @override
  Future<List<VideoModel>> getVideos() async {
    final apiKey = await _getApiKey();
    final List<VideoModel> videos = [];
    for (final channelId in _channelIds) {
      final response = await client.get(
        Uri.parse(
            'https://www.googleapis.com/youtube/v3/search?key=$apiKey&channelId=$channelId&part=snippet,id&order=date&maxResults=10'),
      );
      print(response.body);
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final items = data['items'] as List;
        videos.addAll(items
            .map((item) => VideoModel.fromJson(item as Map<String, dynamic>))
            .toList());
      } else {
        throw Exception('Failed to load videos');
      }
    }
    return videos;
  }
}
