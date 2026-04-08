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

  bool get hasLocation =>
      (city != null && city!.isNotEmpty) ||
      (country != null && country!.isNotEmpty);

  bool get hasCoordinates => latitude != null && longitude != null;

  bool get hasRecordingDate => recordingDate != null;

  String get locationText {
    final parts = <String>[];
    if (city != null && city!.isNotEmpty) parts.add(city!);
    if (country != null && country!.isNotEmpty) parts.add(country!);
    return parts.join(', ');
  }
}
