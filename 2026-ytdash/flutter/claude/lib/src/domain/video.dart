import 'dart:convert';

/// Domain model for a single video, normalized from the YouTube API responses
/// (see youtube-api.md) and independent of any transport detail.
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

  /// The source-channel label this video came from.
  final String category;
  final String thumbnailUrl;
  final double? lat;
  final double? lng;

  bool get hasLocation => lat != null && lng != null;

  /// Canonical watch URL, derived from the id (never trusted from the API).
  String get youtubeUrl => 'https://www.youtube.com/watch?v=$id';

  Video copyWith({String? category, double? lat, double? lng}) => Video(
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
        'publishedAt': publishedAt.toUtc().toIso8601String(),
        'category': category,
        'thumbnailUrl': thumbnailUrl,
        'lat': lat,
        'lng': lng,
      };

  factory Video.fromJson(Map<String, dynamic> json) => Video(
        id: (json['id'] ?? '').toString(),
        title: (json['title'] ?? '').toString(),
        description: (json['description'] ?? '').toString(),
        publishedAt:
            DateTime.tryParse((json['publishedAt'] ?? '').toString())?.toUtc() ??
                DateTime.fromMillisecondsSinceEpoch(0, isUtc: true),
        category: (json['category'] ?? '').toString(),
        thumbnailUrl: (json['thumbnailUrl'] ?? '').toString(),
        lat: (json['lat'] as num?)?.toDouble(),
        lng: (json['lng'] as num?)?.toDouble(),
      );

  static String encodeList(List<Video> videos) =>
      jsonEncode(videos.map((v) => v.toJson()).toList());

  static List<Video> decodeList(String raw) => (jsonDecode(raw) as List)
      .map((e) => Video.fromJson(e as Map<String, dynamic>))
      .toList();
}
