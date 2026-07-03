import 'package:ytdash_flutter/data/models/channel.dart';
import 'package:ytdash_flutter/data/models/video.dart';
import 'package:ytdash_flutter/data/services/cache_service.dart';
import 'package:ytdash_flutter/data/services/geocoding_service.dart';
import 'package:ytdash_flutter/data/services/youtube_service.dart';

class VideoRepository {
  final YoutubeService _youtubeService;
  final CacheService _cacheService;
  final GeocodingService _geocodingService;

  VideoRepository({
    required YoutubeService youtubeService,
    required CacheService cacheService,
    required GeocodingService geocodingService,
  })  : _youtubeService = youtubeService,
        _cacheService = cacheService,
        _geocodingService = geocodingService;

  /// Loads videos. If [forceRefresh] is true or cache is empty, fetches from network.
  /// Deduplicates across channels, reverse geocodes geolocated videos, caches results to disk,
  /// and falls back to stale cache on network failure.
  Future<List<Video>> getVideos({
    required bool forceRefresh,
    required String baseUrl,
    required String apiKey,
    required List<ChannelConfig> channels,
    bool uiTestMode = false,
  }) async {
    // 1. Always load local cache first
    final List<Video> cachedVideos = await _cacheService.loadVideos();

    // 2. Fetch from network if forceRefresh is true or cache is empty
    if (forceRefresh || cachedVideos.isEmpty) {
      try {
        final List<Video> allFetchedVideos = [];

        // Fetch each channel sequentially and merge
        for (final channel in channels) {
          try {
            final List<Video> channelVideos = await _youtubeService.fetchVideosForChannel(
              channelId: channel.id,
              baseUrl: baseUrl,
              apiKey: apiKey,
              categoryLabel: channel.label,
            );
            allFetchedVideos.addAll(channelVideos);
          } catch (e) {
            print('Error fetching channel ${channel.label} (${channel.id}): $e');
            // If fetching any single channel fails, let the error propagate
            // so we can trigger standard fallback logic.
            rethrow;
          }
        }

        if (allFetchedVideos.isNotEmpty) {
          // Deduplicate by video ID
          final Map<String, Video> dedupedMap = {};
          for (final video in allFetchedVideos) {
            dedupedMap[video.id] = video;
          }
          final List<Video> dedupedList = dedupedMap.values.toList();

          // Enrichment: Reverse geocode located videos concurrently
          final List<Future<Video>> futures = dedupedList.map((video) async {
            if (video.lat != null && video.lng != null) {
              try {
                final String locationName = await _geocodingService.reverseGeocode(
                  video.lat!,
                  video.lng!,
                  uiTestMode: uiTestMode,
                );
                return video.copyWith(locationName: locationName);
              } catch (e) {
                print('Geocoding failed for video ${video.id}: $e');
                return video;
              }
            } else {
              return video;
            }
          }).toList();

          final List<Video> enrichedList = await Future.wait(futures);

          // Update local cache
          await _cacheService.saveVideos(enrichedList);
          return enrichedList;
        }
      } catch (e) {
        print('Network fetch failed in repository: $e');
        // If there's a cached list, return it as a silent fallback on network error
        if (cachedVideos.isNotEmpty) {
          print('Network error occurred; returning stale cache as fallback');
          return cachedVideos;
        }
        // If no cache is available, rethrow so UI can display error retry screen
        rethrow;
      }
    }

    return cachedVideos;
  }
}
