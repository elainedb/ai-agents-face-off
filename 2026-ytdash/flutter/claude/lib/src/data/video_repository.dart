import '../config/app_config.dart';
import '../domain/video.dart';
import 'video_cache.dart';
import 'youtube_api.dart';

/// Outcome of a load: the videos plus whether they came from the network or
/// were served stale from the cache after a network failure.
class LoadResult {
  const LoadResult(this.videos, {required this.fromCache});
  final List<Video> videos;
  final bool fromCache;
}

/// Mediates between the network and the local store. The store is the source
/// of truth the UI reads from; the network refreshes it (constitution §1.5).
class VideoRepository {
  VideoRepository({
    required this.api,
    required this.cache,
    required this.channels,
  });

  final YoutubeApi api;
  final VideoCache cache;
  final List<SourceChannel> channels;

  /// Fetches fresh data; on network failure falls back to cached data when
  /// available, rather than failing (AC-CACHE-01). Re-throws only when there
  /// is no cache to fall back to.
  Future<LoadResult> refresh() async {
    try {
      final videos = await api.fetchAllVideos(channels);
      await cache.save(videos);
      return LoadResult(videos, fromCache: false);
    } on ApiException {
      final cached = await cache.load();
      if (cached.isNotEmpty) {
        return LoadResult(cached, fromCache: true);
      }
      rethrow;
    }
  }

  /// The currently cached list (may be empty).
  Future<List<Video>> cached() => cache.load();
}
