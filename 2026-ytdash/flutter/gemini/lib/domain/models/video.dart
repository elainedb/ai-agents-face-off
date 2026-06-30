class Video {
  final String id;
  final String title;
  final String description;
  final String publishedAt; // ISO-8601 string
  final String category; // Maps to source channel's label
  final double? latitude;
  final double? longitude;
  final String thumbnailUrl;

  Video({
    required this.id,
    required this.title,
    required this.description,
    required this.publishedAt,
    required this.category,
    this.latitude,
    this.longitude,
    required this.thumbnailUrl,
  });

  String get youtubeUrl => 'https://www.youtube.com/watch?v=$id';

  factory Video.fromJson(Map<String, dynamic> json) {
    return Video(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      publishedAt: json['publishedAt'] as String,
      category: json['category'] as String,
      latitude: json['latitude'] != null ? (json['latitude'] as num).toDouble() : null,
      longitude: json['longitude'] != null ? (json['longitude'] as num).toDouble() : null,
      thumbnailUrl: json['thumbnailUrl'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'publishedAt': publishedAt,
      'category': category,
      'latitude': latitude,
      'longitude': longitude,
      'thumbnailUrl': thumbnailUrl,
    };
  }

  Video copyWith({
    String? id,
    String? title,
    String? description,
    String? publishedAt,
    String? category,
    double? latitude,
    double? longitude,
    String? thumbnailUrl,
  }) {
    return Video(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      publishedAt: publishedAt ?? this.publishedAt,
      category: category ?? this.category,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      thumbnailUrl: thumbnailUrl ?? this.thumbnailUrl,
    );
  }
}
