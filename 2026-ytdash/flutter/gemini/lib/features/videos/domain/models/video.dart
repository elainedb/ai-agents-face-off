import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'video.g.dart';

@JsonSerializable()
class Video extends Equatable {
  final String id;
  final String title;
  final String description;
  final DateTime publishedAt;
  final String category;
  final String thumbnailUrl;
  final double? lat;
  final double? lng;

  const Video({
    required this.id,
    required this.title,
    required this.description,
    required this.publishedAt,
    required this.category,
    required this.thumbnailUrl,
    this.lat,
    this.lng,
  });

  factory Video.fromJson(Map<String, dynamic> json) => _$VideoFromJson(json);
  Map<String, dynamic> toJson() => _$VideoToJson(this);

  @override
  List<Object?> get props => [
    id,
    title,
    description,
    publishedAt,
    category,
    thumbnailUrl,
    lat,
    lng,
  ];
}
