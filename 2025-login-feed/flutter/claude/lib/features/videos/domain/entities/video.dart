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
    @Default([]) List<String> tags,
    String? city,
    String? country,
    double? latitude,
    double? longitude,
    DateTime? recordingDate,
  }) = _Video;

  const Video._();

  bool get hasLocation => city != null && country != null;
  bool get hasCoordinates => latitude != null && longitude != null;
  bool get hasRecordingDate => recordingDate != null;

  String get locationText {
    if (hasLocation) {
      return '$city, $country';
    } else if (country != null) {
      return country!;
    }
    return '';
  }
}