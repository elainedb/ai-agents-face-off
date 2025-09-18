// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'video_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$VideoModelImpl _$$VideoModelImplFromJson(Map<String, dynamic> json) =>
    _$VideoModelImpl(
      id: json['id'] as String,
      title: json['title'] as String,
      channelTitle: json['channelTitle'] as String,
      thumbnailUrl: json['thumbnailUrl'] as String,
      publishedAt: json['publishedAt'] as String,
    );

Map<String, dynamic> _$$VideoModelImplToJson(_$VideoModelImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'channelTitle': instance.channelTitle,
      'thumbnailUrl': instance.thumbnailUrl,
      'publishedAt': instance.publishedAt,
    };
