import '../entities/video.dart';

sealed class VideoResult {
  const VideoResult();
}

class VideoResultOk extends VideoResult {
  const VideoResultOk(this.videos, {required this.fromCache});
  final List<Video> videos;

  /// True when this result was served from the local cache (network failed or was skipped),
  /// so presentation can decide whether to show a "stale data" affordance if desired.
  final bool fromCache;
}

class VideoResultError extends VideoResult {
  const VideoResultError(this.message);
  final String message;
}

/// Domain-facing abstraction over "where videos come from". Presentation depends on this
/// interface only (constitution §1.2 dependency inversion); `data/video_repository_impl.dart`
/// implements it against the network + local cache.
abstract class VideoRepository {
  /// Fetches all videos across all configured channels (following pagination), replaces the
  /// cache on success, and falls back to the cache on network failure. Never throws.
  Future<VideoResult> refresh();

  /// Returns whatever is currently cached, without touching the network. Used for an instant
  /// first paint before/while [refresh] runs.
  Future<List<Video>> cached();
}
