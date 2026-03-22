import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:ytdash_flutter_gemini/features/videos/domain/entities/video.dart';

part 'video_model.freezed.dart';
part 'video_model.g.dart';

@freezed
abstract class VideoModel with _$VideoModel {
  const VideoModel._();

  const factory VideoModel({
    required String id,
    required String title,
    @JsonKey(name: 'channelTitle') required String channelTitle,
    @JsonKey(name: 'thumbnailUrl') required String thumbnailUrl,
    @JsonKey(name: 'publishedAt') required String publishedAt,
    @Default([]) List<String> tags,
    String? city,
    String? country,
    double? latitude,
    double? longitude,
    @JsonKey(name: 'recordingDate') String? recordingDate,
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
}
