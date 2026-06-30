/// Domain model for a video. Built from the YouTube Data API responses (search.list +
/// videos.list) and mapped per youtube-api.md. `category` is the **source-channel label**
/// (config), not YouTube's numeric categoryId.
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
  final DateTime publishedAt;
  final String category;
  final String thumbnailUrl;
  final double? lat;
  final double? lng;

  bool get hasLocation => lat != null && lng != null;

  /// The canonical external watch URL (constitution selector `detail_video_url`).
  String get youtubeUrl => 'https://www.youtube.com/watch?v=$id';

  Video copyWith({double? lat, double? lng, String? category}) => Video(
        id: id,
        title: title,
        description: description,
        publishedAt: publishedAt,
        category: category ?? this.category,
        thumbnailUrl: thumbnailUrl,
        lat: lat ?? this.lat,
        lng: lng ?? this.lng,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'description': description,
        'publishedAt': publishedAt.toIso8601String(),
        'category': category,
        'thumbnailUrl': thumbnailUrl,
        'lat': lat,
        'lng': lng,
      };

  factory Video.fromJson(Map<String, dynamic> json) => Video(
        id: json['id'] as String,
        title: json['title'] as String? ?? '',
        description: json['description'] as String? ?? '',
        publishedAt:
            DateTime.tryParse(json['publishedAt'] as String? ?? '') ?? DateTime.fromMillisecondsSinceEpoch(0),
        category: json['category'] as String? ?? '',
        thumbnailUrl: json['thumbnailUrl'] as String? ?? '',
        lat: (json['lat'] as num?)?.toDouble(),
        lng: (json['lng'] as num?)?.toDouble(),
      );
}
