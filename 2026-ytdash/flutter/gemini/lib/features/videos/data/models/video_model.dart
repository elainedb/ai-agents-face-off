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
    @JsonKey(name: 'channelTitle') required String channelTitle,
    required String thumbnailUrl,
    required String publishedAt,
    @Default([]) List<String> tags,
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
      recordingDate: recordingDate != null ? DateTime.tryParse(recordingDate!) : null,
    );
  }
  
  factory VideoModel.fromEntity(Video video) {
    return VideoModel(
      id: video.id,
      title: video.title,
      channelTitle: video.channelName,
      thumbnailUrl: video.thumbnailUrl,
      publishedAt: video.publishedAt.toIso8601String(),
      tags: video.tags,
      city: video.city,
      country: video.country,
      latitude: video.latitude,
      longitude: video.longitude,
      recordingDate: video.recordingDate?.toIso8601String(),
    );
  }
}
