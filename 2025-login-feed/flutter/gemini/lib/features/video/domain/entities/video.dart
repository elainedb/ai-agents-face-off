import 'package:freezed_annotation/freezed_annotation.dart';

part 'video.freezed.dart';

@freezed
abstract class Video with _$Video {
  const factory Video({
    required String id,
    required String title,
    required String thumbnailUrl,
    required String channelTitle,
    required DateTime publishedAt,
  }) = _Video;
}
