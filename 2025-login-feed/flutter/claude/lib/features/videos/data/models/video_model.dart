import 'package:freezed_annotation/freezed_annotation.dart';

import '../../domain/entities/video.dart';

part 'video_model.freezed.dart';
part 'video_model.g.dart';

@freezed
class VideoModel with _$VideoModel {
  const factory VideoModel({
    required String id,
    required String title,
    required String channelTitle,
    required String thumbnailUrl,
    required String publishedAt,
  }) = _VideoModel;

  const VideoModel._();

  factory VideoModel.fromJson(Map<String, dynamic> json) =>
      _$VideoModelFromJson(json);

  Video toEntity() {
    return Video(
      id: id,
      title: title,
      channelName: channelTitle,
      thumbnailUrl: thumbnailUrl,
      publishedAt: DateTime.parse(publishedAt),
    );
  }
}