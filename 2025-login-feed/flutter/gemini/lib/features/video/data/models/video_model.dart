import 'package:flutter_gemini/features/video/domain/entities/video.dart';

class VideoModel extends Video {
  const VideoModel({
    required super.id,
    required super.title,
    required super.thumbnailUrl,
    required super.channelTitle,
    required super.publishedAt,
    required super.tags,
    super.locationDescription,
    super.country,
    super.recordingDate,
    super.latitude,
    super.longitude,
  });

  factory VideoModel.fromJson(Map<String, dynamic> json) {
    return VideoModel(
      id: json['id'],
      title: json['snippet']['title'],
      thumbnailUrl: json['snippet']['thumbnails']['high']['url'],
      channelTitle: json['snippet']['channelTitle'],
      publishedAt: DateTime.parse(json['snippet']['publishedAt']),
      tags: List<String>.from(json['snippet']['tags'] ?? []),
      locationDescription:
          json['recordingDetails']?['locationDescription'],
      country: json['recordingDetails']?['location']?['country'],
      recordingDate: json['recordingDetails']?['recordingDate'] != null
          ? DateTime.parse(json['recordingDetails']['recordingDate'])
          : null,
      latitude: json['recordingDetails']?['location']?['latitude'],
      longitude: json['recordingDetails']?['location']?['longitude'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'snippet': {
        'title': title,
        'thumbnails': {
          'high': {'url': thumbnailUrl}
        },
        'channelTitle': channelTitle,
        'publishedAt': publishedAt.toIso8601String(),
        'tags': tags,
      },
      'recordingDetails': {
        'locationDescription': locationDescription,
        'recordingDate': recordingDate?.toIso8601String(),
        'location': {
          'latitude': latitude,
          'longitude': longitude,
          'country': country,
        }
      }
    };
  }
}