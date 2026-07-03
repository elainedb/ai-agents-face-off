class Video {
  final String id;
  final String title;
  final String description;
  final DateTime publishedAt;
  final String category; // The source channel's label
  final double? lat;
  final double? lng;
  final String thumbnailUrl;
  final String youtubeUrl;

  Video({
    required this.id,
    required this.title,
    required this.description,
    required this.publishedAt,
    required this.category,
    this.lat,
    this.lng,
    required this.thumbnailUrl,
    required this.youtubeUrl,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'publishedAt': publishedAt.toIso8601String(),
      'category': category,
      'lat': lat,
      'lng': lng,
      'thumbnailUrl': thumbnailUrl,
      'youtubeUrl': youtubeUrl,
    };
  }

  factory Video.fromJson(Map<String, dynamic> json) {
    return Video(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      publishedAt: DateTime.parse(json['publishedAt'] as String),
      category: json['category'] as String,
      lat: json['lat'] != null ? (json['lat'] as num).toDouble() : null,
      lng: json['lng'] != null ? (json['lng'] as num).toDouble() : null,
      thumbnailUrl: json['thumbnailUrl'] as String,
      youtubeUrl: json['youtubeUrl'] as String,
    );
  }
}
