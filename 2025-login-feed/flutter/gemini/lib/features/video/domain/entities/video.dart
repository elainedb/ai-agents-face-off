import 'package:equatable/equatable.dart';

class Video extends Equatable {
  final String id;
  final String title;
  final String thumbnailUrl;
  final String channelTitle;
  final DateTime publishedAt;
  final List<String> tags;
  final String? locationDescription;
  final String? country;
  final DateTime? recordingDate;
  final double? latitude;
  final double? longitude;

  const Video({
    required this.id,
    required this.title,
    required this.thumbnailUrl,
    required this.channelTitle,
    required this.publishedAt,
    required this.tags,
    this.locationDescription,
    this.country,
    this.recordingDate,
    this.latitude,
    this.longitude,
  });

  @override
  List<Object?> get props => [
        id,
        title,
        thumbnailUrl,
        channelTitle,
        publishedAt,
        tags,
        locationDescription,
        country,
        recordingDate,
        latitude,
        longitude,
      ];
}