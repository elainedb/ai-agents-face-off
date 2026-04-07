import 'dart:convert';

import '../../domain/entities/video.dart';

class VideoModel extends Video {
  VideoModel({
    required super.id,
    required super.title,
    required String channelTitle,
    required super.thumbnailUrl,
    required this.publishedAtRaw,
    required super.tags,
    super.city,
    super.country,
    super.latitude,
    super.longitude,
    this.recordingDateRaw,
    this.locationDescription,
  }) : _channelTitle = channelTitle,
       super(
         channelName: channelTitle,
         publishedAt: DateTime.parse(publishedAtRaw),
         recordingDate: recordingDateRaw == null
             ? null
             : DateTime.tryParse(recordingDateRaw),
       );

  final String _channelTitle;
  final String publishedAtRaw;
  final String? recordingDateRaw;
  final String? locationDescription;

  String get channelTitle => _channelTitle;

  Video toEntity() {
    return Video(
      id: id,
      title: title,
      channelName: channelTitle,
      thumbnailUrl: thumbnailUrl,
      publishedAt: DateTime.parse(publishedAtRaw),
      tags: tags,
      city: city,
      country: country,
      latitude: latitude,
      longitude: longitude,
      recordingDate: recordingDateRaw == null
          ? null
          : DateTime.tryParse(recordingDateRaw!),
    );
  }

  VideoModel copyWith({
    String? city,
    String? country,
  }) {
    return VideoModel(
      id: id,
      title: title,
      channelTitle: channelTitle,
      thumbnailUrl: thumbnailUrl,
      publishedAtRaw: publishedAtRaw,
      tags: tags,
      city: city ?? this.city,
      country: country ?? this.country,
      latitude: latitude,
      longitude: longitude,
      recordingDateRaw: recordingDateRaw,
      locationDescription: locationDescription,
    );
  }

  Map<String, Object?> toDbMap({required String cachedAt}) {
    return {
      'id': id,
      'title': title,
      'channel_title': channelTitle,
      'thumbnail_url': thumbnailUrl,
      'published_at': publishedAtRaw,
      'tags': jsonEncode(tags),
      'city': city,
      'country': country,
      'latitude': latitude,
      'longitude': longitude,
      'recording_date': recordingDateRaw,
      'cached_at': cachedAt,
    };
  }

  factory VideoModel.fromDbMap(Map<String, Object?> map) {
    return VideoModel(
      id: map['id']! as String,
      title: map['title']! as String,
      channelTitle: map['channel_title']! as String,
      thumbnailUrl: map['thumbnail_url']! as String,
      publishedAtRaw: map['published_at']! as String,
      tags: (jsonDecode(map['tags']! as String) as List<dynamic>)
          .map((item) => item.toString())
          .toList(),
      city: map['city'] as String?,
      country: map['country'] as String?,
      latitude: (map['latitude'] as num?)?.toDouble(),
      longitude: (map['longitude'] as num?)?.toDouble(),
      recordingDateRaw: map['recording_date'] as String?,
    );
  }
}
