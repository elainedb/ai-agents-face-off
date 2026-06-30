import '../core/result.dart';
import 'channel_config.dart';
import 'models/video.dart';
import 'video_cache.dart';
import 'youtube_api.dart';

/// Abstraction the presentation layer depends on (constitution §1.2 dependency inversion).
abstract class VideoRepository {
  /// Refresh from the network, persisting on success. On network failure, falls back to the
  /// most recently cached videos rather than failing (constitution §1.5; AC-CACHE-01).
  Future<Result<List<Video>>> getVideos({bool forceRefresh = false});
}

class VideoRepositoryImpl implements VideoRepository {
  VideoRepositoryImpl({
    required this.api,
    required this.cache,
    required this.channels,
  });

  final YoutubeApi api;
  final VideoCache cache;
  final List<SourceChannel> channels;

  @override
  Future<Result<List<Video>>> getVideos({bool forceRefresh = false}) async {
    try {
      final fresh = await api.fetchAllVideos(channels);
      await cache.save(fresh);
      return Ok(fresh);
    } catch (networkError) {
      // Network/parse failure → serve stale cache if we have it; only surface an error when the
      // cache is empty too (constitution §1.6).
      final cached = await cache.load();
      if (cached.isNotEmpty) {
        return Ok(cached);
      }
      return Err(Failure(
        'Could not load videos. Check your connection and retry.',
        cause: networkError,
      ));
    }
  }
}
