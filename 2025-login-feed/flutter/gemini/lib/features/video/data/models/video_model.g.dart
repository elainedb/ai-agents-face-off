// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'video_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_VideoIdModel _$VideoIdModelFromJson(Map<String, dynamic> json) =>
    _VideoIdModel(videoId: json['videoId'] as String?);

Map<String, dynamic> _$VideoIdModelToJson(_VideoIdModel instance) =>
    <String, dynamic>{'videoId': instance.videoId};

_VideoModel _$VideoModelFromJson(Map<String, dynamic> json) => _VideoModel(
  id: VideoIdModel.fromJson(json['id'] as Map<String, dynamic>),
  snippet: json['snippet'] == null
      ? null
      : Snippet.fromJson(json['snippet'] as Map<String, dynamic>),
);

Map<String, dynamic> _$VideoModelToJson(_VideoModel instance) =>
    <String, dynamic>{'id': instance.id, 'snippet': instance.snippet};

_Snippet _$SnippetFromJson(Map<String, dynamic> json) => _Snippet(
  title: json['title'] as String,
  thumbnails: json['thumbnails'] == null
      ? null
      : Thumbnails.fromJson(json['thumbnails'] as Map<String, dynamic>),
  channelTitle: json['channelTitle'] as String,
  publishedAt: DateTime.parse(json['publishedAt'] as String),
);

Map<String, dynamic> _$SnippetToJson(_Snippet instance) => <String, dynamic>{
  'title': instance.title,
  'thumbnails': instance.thumbnails,
  'channelTitle': instance.channelTitle,
  'publishedAt': instance.publishedAt.toIso8601String(),
};

_Thumbnails _$ThumbnailsFromJson(Map<String, dynamic> json) => _Thumbnails(
  high: json['high'] == null
      ? null
      : Thumbnail.fromJson(json['high'] as Map<String, dynamic>),
);

Map<String, dynamic> _$ThumbnailsToJson(_Thumbnails instance) =>
    <String, dynamic>{'high': instance.high};

_Thumbnail _$ThumbnailFromJson(Map<String, dynamic> json) =>
    _Thumbnail(url: json['url'] as String);

Map<String, dynamic> _$ThumbnailToJson(_Thumbnail instance) =>
    <String, dynamic>{'url': instance.url};
