import 'package:equatable/equatable.dart';

class Video extends Equatable {
  const Video({
    required this.id,
    required this.title,
    required this.channelName,
    required this.thumbnailUrl,
    required this.publishedAt,
    required this.tags,
    this.city,
    this.country,
    this.latitude,
    this.longitude,
    this.recordingDate,
  });

  final String id;
  final String title;
  final String channelName;
  final String thumbnailUrl;
  final DateTime publishedAt;
  final List<String> tags;
  final String? city;
  final String? country;
  final double? latitude;
  final double? longitude;
  final DateTime? recordingDate;

  bool get hasLocation =>
      (city != null && city!.isNotEmpty) ||
      (country != null && country!.isNotEmpty);

  bool get hasCoordinates => latitude != null && longitude != null;

  bool get hasRecordingDate => recordingDate != null;

  String get locationText {
    final parts = [
      if (city != null && city!.isNotEmpty) city,
      if (country != null && country!.isNotEmpty) country,
    ];
    return parts.isEmpty ? 'Unknown location' : parts.join(', ');
  }

  @override
  List<Object?> get props => [
    id,
    title,
    channelName,
    thumbnailUrl,
    publishedAt,
    tags,
    city,
    country,
    latitude,
    longitude,
    recordingDate,
  ];
}
