// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'video.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Video _$VideoFromJson(Map<String, dynamic> json) => Video(
  id: json['id'] as String,
  title: json['title'] as String,
  description: json['description'] as String,
  publishedAt: DateTime.parse(json['publishedAt'] as String),
  category: json['category'] as String,
  thumbnailUrl: json['thumbnailUrl'] as String,
  lat: (json['lat'] as num?)?.toDouble(),
  lng: (json['lng'] as num?)?.toDouble(),
);

Map<String, dynamic> _$VideoToJson(Video instance) => <String, dynamic>{
  'id': instance.id,
  'title': instance.title,
  'description': instance.description,
  'publishedAt': instance.publishedAt.toIso8601String(),
  'category': instance.category,
  'thumbnailUrl': instance.thumbnailUrl,
  'lat': instance.lat,
  'lng': instance.lng,
};
