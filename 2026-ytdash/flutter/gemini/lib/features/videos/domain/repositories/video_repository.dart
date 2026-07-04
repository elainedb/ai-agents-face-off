import '../../../../core/error/result.dart';
import '../models/video.dart';

abstract class VideoRepository {
  Future<Result<List<Video>>> getVideos();
}
