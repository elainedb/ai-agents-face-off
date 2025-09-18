import 'package:freezed_annotation/freezed_annotation.dart';

part 'video.freezed.dart';

@freezed
class Video with _$Video {
  const factory Video({
    required String id,
    required String title,
    required String channelName,
    required String thumbnailUrl,
    required DateTime publishedAt,
  }) = _Video;
}