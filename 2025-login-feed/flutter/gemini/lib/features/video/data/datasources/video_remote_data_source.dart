import 'package:flutter_gemini/features/video/data/models/video_model.dart';

abstract class VideoRemoteDataSource {
  Future<List<VideoModel>> getVideos();
}