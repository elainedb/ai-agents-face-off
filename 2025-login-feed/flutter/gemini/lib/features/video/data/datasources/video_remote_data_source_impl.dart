import 'package:dio/dio.dart';
import 'package:flutter_gemini/core/errors/exceptions.dart';
import 'package:flutter_gemini/core/services/api_key_service.dart';
import 'package:flutter_gemini/core/services/reverse_geocoding_service.dart';
import 'package:flutter_gemini/features/video/data/datasources/video_remote_data_source.dart';
import 'package:flutter_gemini/features/video/data/models/video_model.dart';
import 'package:injectable/injectable.dart';

@LazySingleton(as: VideoRemoteDataSource)
class VideoRemoteDataSourceImpl implements VideoRemoteDataSource {
  final Dio dio;
  final ApiKeyService apiKeyService;
  final ReverseGeocodingService geocodingService;

  VideoRemoteDataSourceImpl(this.dio, this.apiKeyService, this.geocodingService);

  final List<String> _channelIds = [
    'UCynoa1DjwnvHAowA_jiMEAQ',
    'UCK0KOjX3beyB9nzonls0cuw',
    'UCACkIrvrGAQ7kuc0hMVwvmA',
    'UCtWRAKKvOEA0CXOue9BG8ZA',
  ];

  @override
  Future<List<VideoModel>> getVideos() async {
    try {
      final apiKey = await apiKeyService.getApiKey();
      List<String> allVideoIds = [];

      for (String channelId in _channelIds) {
        String? nextPageToken;
        do {
          final response = await dio.get(
            'https://www.googleapis.com/youtube/v3/search',
            queryParameters: {
              'part': 'snippet',
              'channelId': channelId,
              'maxResults': 50,
              'order': 'date',
              'type': 'video',
              'key': apiKey.trim(),
              'pageToken': nextPageToken,
            },
          );

          if (response.statusCode == 200) {
            final searchData = response.data;
            final videoIds = (searchData['items'] as List)
                .where((item) =>
                    item['id'] != null &&
                    item['id']['kind'] == 'youtube#video' &&
                    item['id']['videoId'] != null)
                .map((item) => item['id']['videoId'] as String)
                .toList();
            allVideoIds.addAll(videoIds);
            nextPageToken = searchData['nextPageToken'];
          } else {
            nextPageToken = null;
          }
        } while (nextPageToken != null);
      }

      List<VideoModel> videos = [];
      for (var i = 0; i < allVideoIds.length; i += 50) {
        final batchIds = allVideoIds
            .skip(i)
            .take(50)
            .toList();
        final videosResponse = await dio.get(
          'https://www.googleapis.com/youtube/v3/videos',
          queryParameters: {
            'part':
                'snippet,contentDetails,statistics,status,recordingDetails',
            'id': batchIds.join(','),
            'key': apiKey.trim(),
          },
        );

        if (videosResponse.statusCode == 200) {
          final videoListResponse = videosResponse.data;
          videos.addAll((videoListResponse['items'] as List)
              .map((item) => VideoModel.fromJson(item))
              .toList());
        }
      }

      final geocodingFutures = videos.map((video) async {
        if (video.latitude != null && video.longitude != null) {
          final geocodingResult = await geocodingService.getAddress(
              video.latitude, video.longitude);
          if (geocodingResult != null) {
            return VideoModel(
              id: video.id,
              title: video.title,
              thumbnailUrl: video.thumbnailUrl,
              channelTitle: video.channelTitle,
              publishedAt: video.publishedAt,
              tags: video.tags,
              locationDescription: geocodingResult.address,
              country: geocodingResult.country,
              recordingDate: video.recordingDate,
              latitude: video.latitude,
              longitude: video.longitude,
            );
          }
        }
        return video;
      }).toList();

      return await Future.wait(geocodingFutures);
    } on DioException catch (e) {
      throw ServerException();
    } catch (e) {
      throw ServerException();
    }
  }
}