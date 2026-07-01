/// A video aggregated from a configured source channel.
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

  /// The configured source channel's label (constitution: category = channel label, not
  /// YouTube's numeric categoryId).
  final String category;
  final String thumbnailUrl;
  final double? lat;
  final double? lng;

  bool get hasLocation => lat != null && lng != null;

  String get youtubeUrl => 'https://www.youtube.com/watch?v=$id';

  Video copyWithLocation({double? lat, double? lng}) {
    return Video(
      id: id,
      title: title,
      description: description,
      publishedAt: publishedAt,
      category: category,
      thumbnailUrl: thumbnailUrl,
      lat: lat,
      lng: lng,
    );
  }

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

  factory Video.fromJson(Map<String, dynamic> json) {
    return Video(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String? ?? '',
      publishedAt: DateTime.parse(json['publishedAt'] as String),
      category: json['category'] as String? ?? '',
      thumbnailUrl: json['thumbnailUrl'] as String? ?? '',
      lat: (json['lat'] as num?)?.toDouble(),
      lng: (json['lng'] as num?)?.toDouble(),
    );
  }
}
