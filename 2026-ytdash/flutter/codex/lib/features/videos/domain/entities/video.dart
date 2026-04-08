import 'package:freezed_annotation/freezed_annotation.dart';

part 'video.freezed.dart';

@freezed
class Video with _$Video {
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

  bool get hasLocation => (city?.isNotEmpty ?? false) || (country?.isNotEmpty ?? false);

  bool get hasCoordinates => latitude != null && longitude != null;

  bool get hasRecordingDate => recordingDate != null;

  String get locationText {
    final values = <String>[
      if (city?.isNotEmpty ?? false) city!,
      if (country?.isNotEmpty ?? false) country!,
    ];
    return values.join(', ');
  }
}
