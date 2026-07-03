class Video {
  final String id;
  final String title;
  final String description;
  final String publishedAt;
  final String category; // Maps to the channel's label
  final String thumbnailUrl;
  final double? lat;
  final double? lng;
  final String? locationName; // Reverse-geocoded name

  Video({
    required this.id,
    required this.title,
    required this.description,
    required this.publishedAt,
    required this.category,
    required this.thumbnailUrl,
    this.lat,
    this.lng,
    this.locationName,
  });

  String get youtubeUrl => 'https://www.youtube.com/watch?v=$id';

  factory Video.fromJson(Map<String, dynamic> json) {
    return Video(
      id: json['id'] as String,
      title: json['title'] as String? ?? '',
      description: json['description'] as String? ?? '',
      publishedAt: json['publishedAt'] as String? ?? '',
      category: json['category'] as String? ?? '',
      thumbnailUrl: json['thumbnailUrl'] as String? ?? '',
      lat: (json['lat'] as num?)?.toDouble(),
      lng: (json['lng'] as num?)?.toDouble(),
      locationName: json['locationName'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'publishedAt': publishedAt,
      'category': category,
      'thumbnailUrl': thumbnailUrl,
      'lat': lat,
      'lng': lng,
      'locationName': locationName,
    };
  }

  Video copyWith({
    String? id,
    String? title,
    String? description,
    String? publishedAt,
    String? category,
    String? thumbnailUrl,
    double? lat,
    double? lng,
    String? locationName,
  }) {
    return Video(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      publishedAt: publishedAt ?? this.publishedAt,
      category: category ?? this.category,
      thumbnailUrl: thumbnailUrl ?? this.thumbnailUrl,
      lat: lat ?? this.lat,
      lng: lng ?? this.lng,
      locationName: locationName ?? this.locationName,
    );
  }
}
