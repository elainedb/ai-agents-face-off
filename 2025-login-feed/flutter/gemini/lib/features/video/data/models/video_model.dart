import 'package:flutter_gemini/features/video/domain/entities/video.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'video_model.freezed.dart';
part 'video_model.g.dart';

@freezed
abstract class VideoIdModel with _$VideoIdModel {
  const factory VideoIdModel({
    String? videoId,
  }) = _VideoIdModel;

  factory VideoIdModel.fromJson(Map<String, dynamic> json) =>
      _$VideoIdModelFromJson(json);
}

@freezed
abstract class VideoModel with _$VideoModel {
  const factory VideoModel({
    required VideoIdModel id,
    Snippet? snippet,
  }) = _VideoModel;

  factory VideoModel.fromJson(Map<String, dynamic> json) =>
      _$VideoModelFromJson(json);
}

@freezed
abstract class Snippet with _$Snippet {
  const factory Snippet({
    required String title,
    Thumbnails? thumbnails,
    required String channelTitle,
    required DateTime publishedAt,
  }) = _Snippet;

  factory Snippet.fromJson(Map<String, dynamic> json) =>
      _$SnippetFromJson(json);
}

@freezed
abstract class Thumbnails with _$Thumbnails {
  const factory Thumbnails({
    Thumbnail? high,
  }) = _Thumbnails;

  factory Thumbnails.fromJson(Map<String, dynamic> json) =>
      _$ThumbnailsFromJson(json);
}

@freezed
abstract class Thumbnail with _$Thumbnail {
  const factory Thumbnail({
    required String url,
  }) = _Thumbnail;

  factory Thumbnail.fromJson(Map<String, dynamic> json) =>
      _$ThumbnailFromJson(json);
}

extension VideoModelX on VideoModel {
  Video? toEntity() {
    final videoId = id.videoId;
    final snippet = this.snippet;
    final highThumbnailUrl = snippet?.thumbnails?.high?.url;

    if (videoId == null || snippet == null || highThumbnailUrl == null) {
      return null;
    }

    return Video(
      id: videoId,
      title: snippet.title,
      thumbnailUrl: highThumbnailUrl,
      channelTitle: snippet.channelTitle,
      publishedAt: snippet.publishedAt,
    );
  }
}