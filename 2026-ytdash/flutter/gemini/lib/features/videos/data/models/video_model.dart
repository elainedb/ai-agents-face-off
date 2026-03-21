import 'package:freezed_annotation/freezed_annotation.dart';

import '../../domain/entities/video.dart';

part 'video_model.freezed.dart';
part 'video_model.g.dart';

@freezed
abstract class VideoModel with _$VideoModel {
  const VideoModel._();

  const factory VideoModel({
    required String id,
    required String title,
    required String channelTitle,
    required String thumbnailUrl,
    required String publishedAt,
    required List<String> tags,
    String? city,
    String? country,
    double? latitude,
    double? longitude,
    String? recordingDate,
  }) = _VideoModel;

  factory VideoModel.fromJson(Map<String, dynamic> json) => _$VideoModelFromJson(json);

  Video toEntity() {
    return Video(
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
      recordingDate: recordingDate != null ? DateTime.parse(recordingDate!) : null,
    );
  }

  factory VideoModel.fromEntity(Video entity) {
    return VideoModel(
      id: entity.id,
      title: entity.title,
      channelTitle: entity.channelName,
      thumbnailUrl: entity.thumbnailUrl,
      publishedAt: entity.publishedAt.toIso8601String(),
      tags: entity.tags,
      city: entity.city,
      country: entity.country,
      latitude: entity.latitude,
      longitude: entity.longitude,
      recordingDate: entity.recordingDate?.toIso8601String(),
    );
  }
}
