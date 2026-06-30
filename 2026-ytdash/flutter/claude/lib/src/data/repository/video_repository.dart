import '../../config/app_config.dart';
import '../api/youtube_api.dart';
import '../cache/video_cache.dart';
import '../models/video.dart';

/// Outcome of a load: the videos plus whether they came from the network or a
/// stale-cache fallback (so the UI never shows a blocking error when it has
/// something to display — constitution §1.6, AC-CACHE-01).
class LoadResult {
  const LoadResult(this.videos, {required this.fromCache, this.error});
  final List<Video> videos;
  final bool fromCache;
  final String? error;
}

/// Abstraction the presentation layer depends on (dependency inversion §1.2).
abstract class VideoRepository {
  Future<LoadResult> getVideos({required bool forceRefresh});
}

/// Aggregates all configured channels (following pagination), dedupes, persists
/// to the cache, and falls back to the cache on network failure.
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
  Future<LoadResult> getVideos({required bool forceRefresh}) async {
    try {
      final fresh = await api.fetchAllVideos(channels);
      if (fresh.isNotEmpty) {
        await cache.save(fresh);
        return LoadResult(fresh, fromCache: false);
      }
      // Empty network result: serve cache if we have one, else empty.
      final cached = await cache.load();
      if (cached.isNotEmpty) {
        return LoadResult(cached, fromCache: true);
      }
      return const LoadResult([], fromCache: false);
    } catch (e) {
      // Network/parse error → stale-cache fallback (no blocking error if we
      // have cached data); otherwise surface the error.
      final cached = await cache.load();
      if (cached.isNotEmpty) {
        return LoadResult(cached, fromCache: true, error: e.toString());
      }
      return LoadResult(const [], fromCache: false, error: e.toString());
    }
  }
}
