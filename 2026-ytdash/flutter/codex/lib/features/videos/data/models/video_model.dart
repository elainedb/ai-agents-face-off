import '../../domain/entities/video.dart';

class VideoModel {
  const VideoModel({
    required this.id,
    required this.title,
    required this.channelTitle,
    required this.thumbnailUrl,
    required this.publishedAt,
    required this.tags,
    this.city,
    this.country,
    this.latitude,
    this.longitude,
    this.recordingDate,
  });

  final String id;
  final String title;
  final String channelTitle;
  final String thumbnailUrl;
  final String publishedAt;
  final List<String> tags;
  final String? city;
  final String? country;
  final double? latitude;
  final double? longitude;
  final String? recordingDate;

  Video toEntity() {
    return Video(
      id: id,
      title: title,
      channelName: channelTitle,
      thumbnailUrl: thumbnailUrl,
      publishedAt: DateTime.parse(publishedAt).toLocal(),
      tags: tags,
      city: city,
      country: country,
      latitude: latitude,
      longitude: longitude,
      recordingDate: recordingDate == null
          ? null
          : DateTime.parse(recordingDate!).toLocal(),
    );
  }

  Map<String, Object?> toMap({required String cachedAt}) {
    return {
      'id': id,
      'title': title,
      'channel_title': channelTitle,
      'thumbnail_url': thumbnailUrl,
      'published_at': publishedAt,
      'tags': tags.join('||'),
      'city': city,
      'country': country,
      'latitude': latitude,
      'longitude': longitude,
      'recording_date': recordingDate,
      'cached_at': cachedAt,
    };
  }

  factory VideoModel.fromMap(Map<String, Object?> map) {
    return VideoModel(
      id: map['id']! as String,
      title: map['title']! as String,
      channelTitle: map['channel_title']! as String,
      thumbnailUrl: map['thumbnail_url']! as String,
      publishedAt: map['published_at']! as String,
      tags: ((map['tags'] as String?) ?? '')
          .split('||')
          .where((item) => item.isNotEmpty)
          .toList(),
      city: map['city'] as String?,
      country: map['country'] as String?,
      latitude: map['latitude'] as double?,
      longitude: map['longitude'] as double?,
      recordingDate: map['recording_date'] as String?,
    );
  }
}
