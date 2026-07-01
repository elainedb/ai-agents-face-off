import '../domain/models/source_channel.dart';
import '../domain/models/video.dart';
import 'local/video_cache.dart';
import 'remote/youtube_api_client.dart';

sealed class RefreshResult {
  const RefreshResult();
}

class RefreshSucceeded extends RefreshResult {
  const RefreshSucceeded(this.videos);
  final List<Video> videos;
}

/// The network refresh failed but a non-empty cache is still being served — not a
/// user-visible error (constitution §1.5, AC-CACHE-01).
class RefreshFailedWithCache extends RefreshResult {
  const RefreshFailedWithCache(this.cachedVideos, this.error);
  final List<Video> cachedVideos;
  final Object error;
}

/// The network refresh failed and there is nothing cached to fall back to.
class RefreshFailedNoCache extends RefreshResult {
  const RefreshFailedNoCache(this.error);
  final Object error;
}

/// Cache-first repository: the local store is the single source of truth the UI reads from
/// (constitution §1.5); the network only ever replaces the store's contents.
class VideoRepository {
  VideoRepository({
    required YoutubeApiClient apiClient,
    required VideoCache cache,
    required List<SourceChannel> channels,
  }) : _apiClient = apiClient,
       _cache = cache,
       _channels = channels;

  final YoutubeApiClient _apiClient;
  final VideoCache _cache;
  final List<SourceChannel> _channels;

  Future<List<Video>> readCached() => _cache.read();

  /// Fetches all configured channels (each fully paginated), merges/dedupes by id, resolves
  /// locations, writes through to the cache, and returns the fresh list — or falls back to the
  /// existing cache on any failure.
  Future<RefreshResult> refresh() async {
    try {
      final merged = <String, Video>{};
      for (final channel in _channels) {
        final videos = await _apiClient.fetchChannelVideos(channel);
        for (final video in videos) {
          merged[video.id] = video;
        }
      }
      final locations = await _apiClient.fetchLocations(merged.keys.toList());
      final withLocations = merged.values.map((video) {
        final loc = locations[video.id];
        if (loc == null) return video;
        return video.copyWithLocation(lat: loc.$1, lng: loc.$2);
      }).toList();

      await _cache.write(withLocations);
      return RefreshSucceeded(withLocations);
    } catch (e) {
      final cached = await _cache.read();
      if (cached.isNotEmpty) {
        return RefreshFailedWithCache(cached, e);
      }
      return RefreshFailedNoCache(e);
    }
  }
}
