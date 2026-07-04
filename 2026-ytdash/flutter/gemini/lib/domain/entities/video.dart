import 'package:equatable/equatable.dart';

class Video extends Equatable {
  final String id;
  final String title;
  final String description;
  final DateTime publishedAt;
  final String category;
  final String thumbnailUrl;
  final double? lat;
  final double? lng;
  final String duration;

  const Video({
    required this.id,
    required this.title,
    required this.description,
    required this.publishedAt,
    required this.category,
    required this.thumbnailUrl,
    required this.duration,
    this.lat,
    this.lng,
  });

  String get formattedDuration {
    if (duration.isEmpty) return '0:00';
    final match = RegExp(r'PT(?:(\d+)H)?(?:(\d+)M)?(?:(\d+)S)?').firstMatch(duration);
    if (match == null) return duration;
    
    int hours = int.parse(match.group(1) ?? '0');
    int minutes = int.parse(match.group(2) ?? '0');
    int seconds = int.parse(match.group(3) ?? '0');

    if (hours > 0) {
      minutes += hours * 60;
    }

    final mm = minutes.toString();
    final ss = seconds.toString().padLeft(2, '0');
    return '$mm:$ss';
  }

  @override
  List<Object?> get props => [id, title, description, publishedAt, category, thumbnailUrl, duration, lat, lng];
}
