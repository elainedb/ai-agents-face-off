/// Domain model for a single video, framework-neutral and JSON-serializable.
///
/// Maps from BOTH YouTube Data API shapes (`search.list` and `videos.list`,
/// see spec/youtube-api.md) and from our own cache JSON. `category` is the
/// **source-channel label** (config), not YouTube's numeric categoryId.
class Video {
  const Video({
    required this.id,
    required this.title,
    required this.description,
    required this.publishedAt,
    required this.category,
    required this.thumbnailUrl,
    this.lat,
    this.lng,
  });

  final String id;
  final String title;
  final String description;
  final String publishedAt; // ISO-8601 string; sort key
  final String category; // source-channel label
  final String thumbnailUrl;
  final double? lat;
  final double? lng;

  bool get hasLocation => lat != null && lng != null;

  /// The canonical external watch URL.
  String get youtubeUrl => 'https://www.youtube.com/watch?v=$id';

  Video copyWith({double? lat, double? lng}) => Video(
        id: id,
        title: title,
        description: description,
        publishedAt: publishedAt,
        category: category,
        thumbnailUrl: thumbnailUrl,
        lat: lat ?? this.lat,
        lng: lng ?? this.lng,
      );

  /// Parse one item from `search.list` (`id.videoId`) or `playlistItems.list`
  /// (`snippet.resourceId.videoId`). `category` is injected by the caller from
  /// the source channel's config label.
  static Video? fromSearchItem(
    Map<String, dynamic> item, {
    required String category,
  }) {
    final snippet = item['snippet'] as Map<String, dynamic>?;
    if (snippet == null) return null;

    String? videoId;
    final idField = item['id'];
    if (idField is Map) {
      videoId = idField['videoId'] as String?;
    } else if (idField is String) {
      videoId = idField;
    }
    // playlistItems put the id under snippet.resourceId.videoId
    final resourceId = snippet['resourceId'];
    if (videoId == null && resourceId is Map) {
      videoId = resourceId['videoId'] as String?;
    }
    if (videoId == null || videoId.isEmpty) return null;

    return Video(
      id: videoId,
      title: (snippet['title'] as String?) ?? '',
      description: (snippet['description'] as String?) ?? '',
      publishedAt: (snippet['publishedAt'] as String?) ?? '',
      category: category,
      thumbnailUrl: _thumb(snippet['thumbnails']),
    );
  }

  static String _thumb(dynamic thumbnails) {
    if (thumbnails is Map) {
      for (final key in ['medium', 'high', 'default']) {
        final t = thumbnails[key];
        if (t is Map && t['url'] is String) return t['url'] as String;
      }
    }
    return '';
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'description': description,
        'publishedAt': publishedAt,
        'category': category,
        'thumbnailUrl': thumbnailUrl,
        'lat': lat,
        'lng': lng,
      };

  factory Video.fromJson(Map<String, dynamic> j) => Video(
        id: j['id'] as String,
        title: (j['title'] as String?) ?? '',
        description: (j['description'] as String?) ?? '',
        publishedAt: (j['publishedAt'] as String?) ?? '',
        category: (j['category'] as String?) ?? '',
        thumbnailUrl: (j['thumbnailUrl'] as String?) ?? '',
        lat: (j['lat'] as num?)?.toDouble(),
        lng: (j['lng'] as num?)?.toDouble(),
      );
}
