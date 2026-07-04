class ChannelConfig {
  final String id;
  final String label;

  ChannelConfig({required this.id, required this.label});

  factory ChannelConfig.fromJson(Map<String, dynamic> json) {
    return ChannelConfig(
      id: json['id'] as String,
      label: json['label'] as String,
    );
  }
}

class Location {
  final double lat;
  final double lng;

  Location({required this.lat, required this.lng});

  factory Location.fromJson(Map<String, dynamic> json) {
    return Location(
      lat: (json['lat'] as num).toDouble(),
      lng: (json['lng'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() => {
        'lat': lat,
        'lng': lng,
      };
}

class Video {
  final String id;
  final String title;
  final String description;
  final DateTime publishedAt;
  final String category;
  final Location? location;
  final String thumbnailUrl;

  String get youtubeUrl => 'https://www.youtube.com/watch?v=$id';

  Video({
    required this.id,
    required this.title,
    required this.description,
    required this.publishedAt,
    required this.category,
    this.location,
    required this.thumbnailUrl,
  });

  factory Video.fromJson(Map<String, dynamic> json) {
    return Video(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      publishedAt: DateTime.parse(json['publishedAt'] as String),
      category: json['category'] as String,
      location: json['location'] != null
          ? Location.fromJson(json['location'] as Map<String, dynamic>)
          : null,
      thumbnailUrl: json['thumbnailUrl'] as String,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'description': description,
        'publishedAt': publishedAt.toIso8601String(),
        'category': category,
        'location': location?.toJson(),
        'thumbnailUrl': thumbnailUrl,
      };
}
