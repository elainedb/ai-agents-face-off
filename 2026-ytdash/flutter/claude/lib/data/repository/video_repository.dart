import '../models/video.dart';

/// Presentation depends on this abstraction, not a concrete data source (constitution §1.2).
abstract class VideoRepository {
  /// Fetches fresh videos from the network across every configured channel, persists them, and
  /// returns the merged/deduped list. On network failure, falls back to the last cached list
  /// (constitution §1.5) — throws only if there is no cache to fall back to.
  Future<List<Video>> fetchVideos();
}
