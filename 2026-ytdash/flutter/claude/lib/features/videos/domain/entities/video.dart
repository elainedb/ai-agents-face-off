import 'package:freezed_annotation/freezed_annotation.dart';

part 'video.freezed.dart';

@freezed
abstract class Video with _$Video {
  const Video._();

  const factory Video({
    required String id,
    required String title,
    required String channelName,
    required String thumbnailUrl,
    required DateTime publishedAt,
    required List<String> tags,
    String? city,
    String? country,
    double? latitude,
    double? longitude,
    DateTime? recordingDate,
  }) = _Video;

  bool get hasLocation => city != null || country != null;
  bool get hasCoordinates => latitude != null && longitude != null;
  bool get hasRecordingDate => recordingDate != null;

  String get locationText {
    if (city != null && country != null) return '$city, $country';
    if (city != null) return city!;
    if (country != null) return country!;
    return '';
  }
}
