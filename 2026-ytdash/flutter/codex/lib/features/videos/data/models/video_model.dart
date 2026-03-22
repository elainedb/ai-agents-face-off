import 'dart:convert';

import 'package:freezed_annotation/freezed_annotation.dart';

import '../../domain/entities/video.dart';

part 'video_model.freezed.dart';
part 'video_model.g.dart';

@freezed
class VideoModel with _$VideoModel {
  const VideoModel._();

  const factory VideoModel({
    required String id,
    required String title,
    required String channelTitle,
    required String thumbnailUrl,
    required String publishedAt,
    @Default(<String>[]) List<String> tags,
    String? city,
    String? country,
    double? latitude,
    double? longitude,
    String? recordingDate,
  }) = _VideoModel;

  factory VideoModel.fromJson(Map<String, dynamic> json) =>
      _$VideoModelFromJson(json);

  Video toEntity() => Video(
    id: id,
    title: title,
    channelName: channelTitle,
    thumbnailUrl: thumbnailUrl,
    publishedAt: DateTime.parse(publishedAt),
    tags: tags,
    city: city,
    country: country,
    latitude: latitude,
    longitude: longitude,
    recordingDate: recordingDate == null || recordingDate!.isEmpty
        ? null
        : DateTime.parse(recordingDate!),
  );

  Map<String, dynamic> toDbMap(DateTime cachedAt) {
    return <String, dynamic>{
      'id': id,
      'title': title,
      'channel_title': channelTitle,
      'thumbnail_url': thumbnailUrl,
      'published_at': publishedAt,
      'tags': jsonEncode(tags),
      'city': city,
      'country': country,
      'latitude': latitude,
      'longitude': longitude,
      'recording_date': recordingDate,
      'cached_at': cachedAt.toIso8601String(),
    };
  }

  factory VideoModel.fromDbMap(Map<String, dynamic> map) {
    return VideoModel(
      id: map['id'] as String,
      title: map['title'] as String,
      channelTitle: map['channel_title'] as String,
      thumbnailUrl: map['thumbnail_url'] as String,
      publishedAt: map['published_at'] as String,
      tags: (jsonDecode(map['tags'] as String) as List<dynamic>)
          .map((item) => item.toString())
          .toList(),
      city: map['city'] as String?,
      country: map['country'] as String?,
      latitude: map['latitude'] as double?,
      longitude: map['longitude'] as double?,
      recordingDate: map['recording_date'] as String?,
    );
  }
}
