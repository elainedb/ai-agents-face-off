
import 'package:equatable/equatable.dart';
import 'package:latlong2/latlong.dart';

class VideoLocation extends Equatable {
  final String id;
  final String title;
  final String thumbnailUrl;
  final String channelTitle;
  final DateTime publicationDate;
  final List<String> tags;
  final String? city;
  final String? country;
  final LatLng coordinates;
  final DateTime? recordingDate;
  final String videoUrl;

  const VideoLocation({
    required this.id,
    required this.title,
    required this.thumbnailUrl,
    required this.channelTitle,
    required this.publicationDate,
    required this.tags,
    this.city,
    this.country,
    required this.coordinates,
    this.recordingDate,
    required this.videoUrl,
  });

  @override
  List<Object?> get props => [
        id,
        title,
        thumbnailUrl,
        channelTitle,
        publicationDate,
        tags,
        city,
        country,
        coordinates,
        recordingDate,
        videoUrl,
      ];
}
