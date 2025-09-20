import 'package:flutter_gemini/features/video/data/models/video_model.dart';

abstract class VideoLocalDataSource {
  Future<List<VideoModel>> getVideos();
  Future<void> cacheVideos(List<VideoModel> videos);
  Future<void> clearVideos();
}
