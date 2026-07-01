import '../../domain/entities/video.dart';

/// One `search.list` (or `playlistItems.list`) result item, tagged with the label of the
/// configured channel it was fetched for (constitution: category = the source channel's label).
class SearchItemDto {
  const SearchItemDto({
    required this.id,
    required this.title,
    required this.description,
    required this.publishedAt,
    required this.thumbnailUrl,
    required this.categoryLabel,
  });

  final String id;
  final String title;
  final String description;
  final DateTime publishedAt;
  final String thumbnailUrl;
  final String categoryLabel;

  factory SearchItemDto.fromSearchJson(
    Map<String, dynamic> json,
    String categoryLabel,
  ) {
    final snippet = json['snippet'] as Map<String, dynamic>? ?? const {};
    final idField = json['id'];
    final videoId = idField is Map<String, dynamic>
        ? idField['videoId'] as String?
        : idField as String?;
    return SearchItemDto(
      id: videoId ?? '',
      title: snippet['title'] as String? ?? '',
      description: snippet['description'] as String? ?? '',
      publishedAt:
          DateTime.tryParse(snippet['publishedAt'] as String? ?? '') ??
          DateTime.fromMillisecondsSinceEpoch(0),
      thumbnailUrl: _thumbnailFrom(snippet),
      categoryLabel: categoryLabel,
    );
  }

  factory SearchItemDto.fromPlaylistItemJson(
    Map<String, dynamic> json,
    String categoryLabel,
  ) {
    final snippet = json['snippet'] as Map<String, dynamic>? ?? const {};
    final resourceId = snippet['resourceId'] as Map<String, dynamic>?;
    return SearchItemDto(
      id: resourceId?['videoId'] as String? ?? '',
      title: snippet['title'] as String? ?? '',
      description: snippet['description'] as String? ?? '',
      publishedAt:
          DateTime.tryParse(snippet['publishedAt'] as String? ?? '') ??
          DateTime.fromMillisecondsSinceEpoch(0),
      thumbnailUrl: _thumbnailFrom(snippet),
      categoryLabel: categoryLabel,
    );
  }

  static String _thumbnailFrom(Map<String, dynamic> snippet) {
    final thumbs = snippet['thumbnails'] as Map<String, dynamic>?;
    if (thumbs == null) return '';
    final medium = thumbs['medium'] as Map<String, dynamic>?;
    final byDefault = thumbs['default'] as Map<String, dynamic>?;
    final high = thumbs['high'] as Map<String, dynamic>?;
    return (medium ?? high ?? byDefault)?['url'] as String? ?? '';
  }
}

/// The location-bearing detail from `videos.list`, keyed by video id.
class VideoDetailsDto {
  const VideoDetailsDto({required this.id, this.lat, this.lng});

  final String id;
  final double? lat;
  final double? lng;

  factory VideoDetailsDto.fromJson(Map<String, dynamic> json) {
    final recording = json['recordingDetails'] as Map<String, dynamic>?;
    final location = recording?['location'] as Map<String, dynamic>?;
    return VideoDetailsDto(
      id: json['id'] as String,
      lat: (location?['latitude'] as num?)?.toDouble(),
      lng: (location?['longitude'] as num?)?.toDouble(),
    );
  }
}

/// Merges search results with their (optional) location details into domain [Video]s, deduping by
/// id (a video could in principle surface from more than one configured channel).
List<Video> mergeToVideos(
  List<SearchItemDto> items,
  Map<String, VideoDetailsDto> details,
) {
  final byId = <String, Video>{};
  for (final item in items) {
    if (item.id.isEmpty || byId.containsKey(item.id)) continue;
    final detail = details[item.id];
    byId[item.id] = Video(
      id: item.id,
      title: item.title,
      description: item.description,
      publishedAt: item.publishedAt,
      category: item.categoryLabel,
      thumbnailUrl: item.thumbnailUrl,
      lat: detail?.lat,
      lng: detail?.lng,
    );
  }
  return byId.values.toList(growable: false);
}
