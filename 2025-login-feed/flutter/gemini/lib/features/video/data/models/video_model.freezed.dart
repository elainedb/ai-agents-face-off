// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'video_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$VideoIdModel {

 String? get videoId;
/// Create a copy of VideoIdModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$VideoIdModelCopyWith<VideoIdModel> get copyWith => _$VideoIdModelCopyWithImpl<VideoIdModel>(this as VideoIdModel, _$identity);

  /// Serializes this VideoIdModel to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is VideoIdModel&&(identical(other.videoId, videoId) || other.videoId == videoId));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,videoId);

@override
String toString() {
  return 'VideoIdModel(videoId: $videoId)';
}


}

/// @nodoc
abstract mixin class $VideoIdModelCopyWith<$Res>  {
  factory $VideoIdModelCopyWith(VideoIdModel value, $Res Function(VideoIdModel) _then) = _$VideoIdModelCopyWithImpl;
@useResult
$Res call({
 String? videoId
});




}
/// @nodoc
class _$VideoIdModelCopyWithImpl<$Res>
    implements $VideoIdModelCopyWith<$Res> {
  _$VideoIdModelCopyWithImpl(this._self, this._then);

  final VideoIdModel _self;
  final $Res Function(VideoIdModel) _then;

/// Create a copy of VideoIdModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? videoId = freezed,}) {
  return _then(_self.copyWith(
videoId: freezed == videoId ? _self.videoId : videoId // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [VideoIdModel].
extension VideoIdModelPatterns on VideoIdModel {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _VideoIdModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _VideoIdModel() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _VideoIdModel value)  $default,){
final _that = this;
switch (_that) {
case _VideoIdModel():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _VideoIdModel value)?  $default,){
final _that = this;
switch (_that) {
case _VideoIdModel() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String? videoId)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _VideoIdModel() when $default != null:
return $default(_that.videoId);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String? videoId)  $default,) {final _that = this;
switch (_that) {
case _VideoIdModel():
return $default(_that.videoId);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String? videoId)?  $default,) {final _that = this;
switch (_that) {
case _VideoIdModel() when $default != null:
return $default(_that.videoId);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _VideoIdModel implements VideoIdModel {
  const _VideoIdModel({this.videoId});
  factory _VideoIdModel.fromJson(Map<String, dynamic> json) => _$VideoIdModelFromJson(json);

@override final  String? videoId;

/// Create a copy of VideoIdModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$VideoIdModelCopyWith<_VideoIdModel> get copyWith => __$VideoIdModelCopyWithImpl<_VideoIdModel>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$VideoIdModelToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _VideoIdModel&&(identical(other.videoId, videoId) || other.videoId == videoId));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,videoId);

@override
String toString() {
  return 'VideoIdModel(videoId: $videoId)';
}


}

/// @nodoc
abstract mixin class _$VideoIdModelCopyWith<$Res> implements $VideoIdModelCopyWith<$Res> {
  factory _$VideoIdModelCopyWith(_VideoIdModel value, $Res Function(_VideoIdModel) _then) = __$VideoIdModelCopyWithImpl;
@override @useResult
$Res call({
 String? videoId
});




}
/// @nodoc
class __$VideoIdModelCopyWithImpl<$Res>
    implements _$VideoIdModelCopyWith<$Res> {
  __$VideoIdModelCopyWithImpl(this._self, this._then);

  final _VideoIdModel _self;
  final $Res Function(_VideoIdModel) _then;

/// Create a copy of VideoIdModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? videoId = freezed,}) {
  return _then(_VideoIdModel(
videoId: freezed == videoId ? _self.videoId : videoId // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}


/// @nodoc
mixin _$VideoModel {

 VideoIdModel get id; Snippet? get snippet;
/// Create a copy of VideoModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$VideoModelCopyWith<VideoModel> get copyWith => _$VideoModelCopyWithImpl<VideoModel>(this as VideoModel, _$identity);

  /// Serializes this VideoModel to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is VideoModel&&(identical(other.id, id) || other.id == id)&&(identical(other.snippet, snippet) || other.snippet == snippet));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,snippet);

@override
String toString() {
  return 'VideoModel(id: $id, snippet: $snippet)';
}


}

/// @nodoc
abstract mixin class $VideoModelCopyWith<$Res>  {
  factory $VideoModelCopyWith(VideoModel value, $Res Function(VideoModel) _then) = _$VideoModelCopyWithImpl;
@useResult
$Res call({
 VideoIdModel id, Snippet? snippet
});


$VideoIdModelCopyWith<$Res> get id;$SnippetCopyWith<$Res>? get snippet;

}
/// @nodoc
class _$VideoModelCopyWithImpl<$Res>
    implements $VideoModelCopyWith<$Res> {
  _$VideoModelCopyWithImpl(this._self, this._then);

  final VideoModel _self;
  final $Res Function(VideoModel) _then;

/// Create a copy of VideoModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? snippet = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as VideoIdModel,snippet: freezed == snippet ? _self.snippet : snippet // ignore: cast_nullable_to_non_nullable
as Snippet?,
  ));
}
/// Create a copy of VideoModel
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$VideoIdModelCopyWith<$Res> get id {
  
  return $VideoIdModelCopyWith<$Res>(_self.id, (value) {
    return _then(_self.copyWith(id: value));
  });
}/// Create a copy of VideoModel
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$SnippetCopyWith<$Res>? get snippet {
    if (_self.snippet == null) {
    return null;
  }

  return $SnippetCopyWith<$Res>(_self.snippet!, (value) {
    return _then(_self.copyWith(snippet: value));
  });
}
}


/// Adds pattern-matching-related methods to [VideoModel].
extension VideoModelPatterns on VideoModel {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _VideoModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _VideoModel() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _VideoModel value)  $default,){
final _that = this;
switch (_that) {
case _VideoModel():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _VideoModel value)?  $default,){
final _that = this;
switch (_that) {
case _VideoModel() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( VideoIdModel id,  Snippet? snippet)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _VideoModel() when $default != null:
return $default(_that.id,_that.snippet);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( VideoIdModel id,  Snippet? snippet)  $default,) {final _that = this;
switch (_that) {
case _VideoModel():
return $default(_that.id,_that.snippet);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( VideoIdModel id,  Snippet? snippet)?  $default,) {final _that = this;
switch (_that) {
case _VideoModel() when $default != null:
return $default(_that.id,_that.snippet);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _VideoModel implements VideoModel {
  const _VideoModel({required this.id, this.snippet});
  factory _VideoModel.fromJson(Map<String, dynamic> json) => _$VideoModelFromJson(json);

@override final  VideoIdModel id;
@override final  Snippet? snippet;

/// Create a copy of VideoModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$VideoModelCopyWith<_VideoModel> get copyWith => __$VideoModelCopyWithImpl<_VideoModel>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$VideoModelToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _VideoModel&&(identical(other.id, id) || other.id == id)&&(identical(other.snippet, snippet) || other.snippet == snippet));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,snippet);

@override
String toString() {
  return 'VideoModel(id: $id, snippet: $snippet)';
}


}

/// @nodoc
abstract mixin class _$VideoModelCopyWith<$Res> implements $VideoModelCopyWith<$Res> {
  factory _$VideoModelCopyWith(_VideoModel value, $Res Function(_VideoModel) _then) = __$VideoModelCopyWithImpl;
@override @useResult
$Res call({
 VideoIdModel id, Snippet? snippet
});


@override $VideoIdModelCopyWith<$Res> get id;@override $SnippetCopyWith<$Res>? get snippet;

}
/// @nodoc
class __$VideoModelCopyWithImpl<$Res>
    implements _$VideoModelCopyWith<$Res> {
  __$VideoModelCopyWithImpl(this._self, this._then);

  final _VideoModel _self;
  final $Res Function(_VideoModel) _then;

/// Create a copy of VideoModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? snippet = freezed,}) {
  return _then(_VideoModel(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as VideoIdModel,snippet: freezed == snippet ? _self.snippet : snippet // ignore: cast_nullable_to_non_nullable
as Snippet?,
  ));
}

/// Create a copy of VideoModel
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$VideoIdModelCopyWith<$Res> get id {
  
  return $VideoIdModelCopyWith<$Res>(_self.id, (value) {
    return _then(_self.copyWith(id: value));
  });
}/// Create a copy of VideoModel
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$SnippetCopyWith<$Res>? get snippet {
    if (_self.snippet == null) {
    return null;
  }

  return $SnippetCopyWith<$Res>(_self.snippet!, (value) {
    return _then(_self.copyWith(snippet: value));
  });
}
}


/// @nodoc
mixin _$Snippet {

 String get title; Thumbnails? get thumbnails; String get channelTitle; DateTime get publishedAt;
/// Create a copy of Snippet
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SnippetCopyWith<Snippet> get copyWith => _$SnippetCopyWithImpl<Snippet>(this as Snippet, _$identity);

  /// Serializes this Snippet to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Snippet&&(identical(other.title, title) || other.title == title)&&(identical(other.thumbnails, thumbnails) || other.thumbnails == thumbnails)&&(identical(other.channelTitle, channelTitle) || other.channelTitle == channelTitle)&&(identical(other.publishedAt, publishedAt) || other.publishedAt == publishedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,title,thumbnails,channelTitle,publishedAt);

@override
String toString() {
  return 'Snippet(title: $title, thumbnails: $thumbnails, channelTitle: $channelTitle, publishedAt: $publishedAt)';
}


}

/// @nodoc
abstract mixin class $SnippetCopyWith<$Res>  {
  factory $SnippetCopyWith(Snippet value, $Res Function(Snippet) _then) = _$SnippetCopyWithImpl;
@useResult
$Res call({
 String title, Thumbnails? thumbnails, String channelTitle, DateTime publishedAt
});


$ThumbnailsCopyWith<$Res>? get thumbnails;

}
/// @nodoc
class _$SnippetCopyWithImpl<$Res>
    implements $SnippetCopyWith<$Res> {
  _$SnippetCopyWithImpl(this._self, this._then);

  final Snippet _self;
  final $Res Function(Snippet) _then;

/// Create a copy of Snippet
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? title = null,Object? thumbnails = freezed,Object? channelTitle = null,Object? publishedAt = null,}) {
  return _then(_self.copyWith(
title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,thumbnails: freezed == thumbnails ? _self.thumbnails : thumbnails // ignore: cast_nullable_to_non_nullable
as Thumbnails?,channelTitle: null == channelTitle ? _self.channelTitle : channelTitle // ignore: cast_nullable_to_non_nullable
as String,publishedAt: null == publishedAt ? _self.publishedAt : publishedAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}
/// Create a copy of Snippet
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ThumbnailsCopyWith<$Res>? get thumbnails {
    if (_self.thumbnails == null) {
    return null;
  }

  return $ThumbnailsCopyWith<$Res>(_self.thumbnails!, (value) {
    return _then(_self.copyWith(thumbnails: value));
  });
}
}


/// Adds pattern-matching-related methods to [Snippet].
extension SnippetPatterns on Snippet {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Snippet value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Snippet() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Snippet value)  $default,){
final _that = this;
switch (_that) {
case _Snippet():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Snippet value)?  $default,){
final _that = this;
switch (_that) {
case _Snippet() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String title,  Thumbnails? thumbnails,  String channelTitle,  DateTime publishedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Snippet() when $default != null:
return $default(_that.title,_that.thumbnails,_that.channelTitle,_that.publishedAt);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String title,  Thumbnails? thumbnails,  String channelTitle,  DateTime publishedAt)  $default,) {final _that = this;
switch (_that) {
case _Snippet():
return $default(_that.title,_that.thumbnails,_that.channelTitle,_that.publishedAt);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String title,  Thumbnails? thumbnails,  String channelTitle,  DateTime publishedAt)?  $default,) {final _that = this;
switch (_that) {
case _Snippet() when $default != null:
return $default(_that.title,_that.thumbnails,_that.channelTitle,_that.publishedAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Snippet implements Snippet {
  const _Snippet({required this.title, this.thumbnails, required this.channelTitle, required this.publishedAt});
  factory _Snippet.fromJson(Map<String, dynamic> json) => _$SnippetFromJson(json);

@override final  String title;
@override final  Thumbnails? thumbnails;
@override final  String channelTitle;
@override final  DateTime publishedAt;

/// Create a copy of Snippet
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SnippetCopyWith<_Snippet> get copyWith => __$SnippetCopyWithImpl<_Snippet>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$SnippetToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Snippet&&(identical(other.title, title) || other.title == title)&&(identical(other.thumbnails, thumbnails) || other.thumbnails == thumbnails)&&(identical(other.channelTitle, channelTitle) || other.channelTitle == channelTitle)&&(identical(other.publishedAt, publishedAt) || other.publishedAt == publishedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,title,thumbnails,channelTitle,publishedAt);

@override
String toString() {
  return 'Snippet(title: $title, thumbnails: $thumbnails, channelTitle: $channelTitle, publishedAt: $publishedAt)';
}


}

/// @nodoc
abstract mixin class _$SnippetCopyWith<$Res> implements $SnippetCopyWith<$Res> {
  factory _$SnippetCopyWith(_Snippet value, $Res Function(_Snippet) _then) = __$SnippetCopyWithImpl;
@override @useResult
$Res call({
 String title, Thumbnails? thumbnails, String channelTitle, DateTime publishedAt
});


@override $ThumbnailsCopyWith<$Res>? get thumbnails;

}
/// @nodoc
class __$SnippetCopyWithImpl<$Res>
    implements _$SnippetCopyWith<$Res> {
  __$SnippetCopyWithImpl(this._self, this._then);

  final _Snippet _self;
  final $Res Function(_Snippet) _then;

/// Create a copy of Snippet
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? title = null,Object? thumbnails = freezed,Object? channelTitle = null,Object? publishedAt = null,}) {
  return _then(_Snippet(
title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,thumbnails: freezed == thumbnails ? _self.thumbnails : thumbnails // ignore: cast_nullable_to_non_nullable
as Thumbnails?,channelTitle: null == channelTitle ? _self.channelTitle : channelTitle // ignore: cast_nullable_to_non_nullable
as String,publishedAt: null == publishedAt ? _self.publishedAt : publishedAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}

/// Create a copy of Snippet
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ThumbnailsCopyWith<$Res>? get thumbnails {
    if (_self.thumbnails == null) {
    return null;
  }

  return $ThumbnailsCopyWith<$Res>(_self.thumbnails!, (value) {
    return _then(_self.copyWith(thumbnails: value));
  });
}
}


/// @nodoc
mixin _$Thumbnails {

 Thumbnail? get high;
/// Create a copy of Thumbnails
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ThumbnailsCopyWith<Thumbnails> get copyWith => _$ThumbnailsCopyWithImpl<Thumbnails>(this as Thumbnails, _$identity);

  /// Serializes this Thumbnails to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Thumbnails&&(identical(other.high, high) || other.high == high));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,high);

@override
String toString() {
  return 'Thumbnails(high: $high)';
}


}

/// @nodoc
abstract mixin class $ThumbnailsCopyWith<$Res>  {
  factory $ThumbnailsCopyWith(Thumbnails value, $Res Function(Thumbnails) _then) = _$ThumbnailsCopyWithImpl;
@useResult
$Res call({
 Thumbnail? high
});


$ThumbnailCopyWith<$Res>? get high;

}
/// @nodoc
class _$ThumbnailsCopyWithImpl<$Res>
    implements $ThumbnailsCopyWith<$Res> {
  _$ThumbnailsCopyWithImpl(this._self, this._then);

  final Thumbnails _self;
  final $Res Function(Thumbnails) _then;

/// Create a copy of Thumbnails
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? high = freezed,}) {
  return _then(_self.copyWith(
high: freezed == high ? _self.high : high // ignore: cast_nullable_to_non_nullable
as Thumbnail?,
  ));
}
/// Create a copy of Thumbnails
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ThumbnailCopyWith<$Res>? get high {
    if (_self.high == null) {
    return null;
  }

  return $ThumbnailCopyWith<$Res>(_self.high!, (value) {
    return _then(_self.copyWith(high: value));
  });
}
}


/// Adds pattern-matching-related methods to [Thumbnails].
extension ThumbnailsPatterns on Thumbnails {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Thumbnails value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Thumbnails() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Thumbnails value)  $default,){
final _that = this;
switch (_that) {
case _Thumbnails():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Thumbnails value)?  $default,){
final _that = this;
switch (_that) {
case _Thumbnails() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( Thumbnail? high)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Thumbnails() when $default != null:
return $default(_that.high);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( Thumbnail? high)  $default,) {final _that = this;
switch (_that) {
case _Thumbnails():
return $default(_that.high);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( Thumbnail? high)?  $default,) {final _that = this;
switch (_that) {
case _Thumbnails() when $default != null:
return $default(_that.high);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Thumbnails implements Thumbnails {
  const _Thumbnails({this.high});
  factory _Thumbnails.fromJson(Map<String, dynamic> json) => _$ThumbnailsFromJson(json);

@override final  Thumbnail? high;

/// Create a copy of Thumbnails
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ThumbnailsCopyWith<_Thumbnails> get copyWith => __$ThumbnailsCopyWithImpl<_Thumbnails>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ThumbnailsToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Thumbnails&&(identical(other.high, high) || other.high == high));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,high);

@override
String toString() {
  return 'Thumbnails(high: $high)';
}


}

/// @nodoc
abstract mixin class _$ThumbnailsCopyWith<$Res> implements $ThumbnailsCopyWith<$Res> {
  factory _$ThumbnailsCopyWith(_Thumbnails value, $Res Function(_Thumbnails) _then) = __$ThumbnailsCopyWithImpl;
@override @useResult
$Res call({
 Thumbnail? high
});


@override $ThumbnailCopyWith<$Res>? get high;

}
/// @nodoc
class __$ThumbnailsCopyWithImpl<$Res>
    implements _$ThumbnailsCopyWith<$Res> {
  __$ThumbnailsCopyWithImpl(this._self, this._then);

  final _Thumbnails _self;
  final $Res Function(_Thumbnails) _then;

/// Create a copy of Thumbnails
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? high = freezed,}) {
  return _then(_Thumbnails(
high: freezed == high ? _self.high : high // ignore: cast_nullable_to_non_nullable
as Thumbnail?,
  ));
}

/// Create a copy of Thumbnails
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ThumbnailCopyWith<$Res>? get high {
    if (_self.high == null) {
    return null;
  }

  return $ThumbnailCopyWith<$Res>(_self.high!, (value) {
    return _then(_self.copyWith(high: value));
  });
}
}


/// @nodoc
mixin _$Thumbnail {

 String get url;
/// Create a copy of Thumbnail
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ThumbnailCopyWith<Thumbnail> get copyWith => _$ThumbnailCopyWithImpl<Thumbnail>(this as Thumbnail, _$identity);

  /// Serializes this Thumbnail to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Thumbnail&&(identical(other.url, url) || other.url == url));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,url);

@override
String toString() {
  return 'Thumbnail(url: $url)';
}


}

/// @nodoc
abstract mixin class $ThumbnailCopyWith<$Res>  {
  factory $ThumbnailCopyWith(Thumbnail value, $Res Function(Thumbnail) _then) = _$ThumbnailCopyWithImpl;
@useResult
$Res call({
 String url
});




}
/// @nodoc
class _$ThumbnailCopyWithImpl<$Res>
    implements $ThumbnailCopyWith<$Res> {
  _$ThumbnailCopyWithImpl(this._self, this._then);

  final Thumbnail _self;
  final $Res Function(Thumbnail) _then;

/// Create a copy of Thumbnail
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? url = null,}) {
  return _then(_self.copyWith(
url: null == url ? _self.url : url // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [Thumbnail].
extension ThumbnailPatterns on Thumbnail {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Thumbnail value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Thumbnail() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Thumbnail value)  $default,){
final _that = this;
switch (_that) {
case _Thumbnail():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Thumbnail value)?  $default,){
final _that = this;
switch (_that) {
case _Thumbnail() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String url)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Thumbnail() when $default != null:
return $default(_that.url);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String url)  $default,) {final _that = this;
switch (_that) {
case _Thumbnail():
return $default(_that.url);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String url)?  $default,) {final _that = this;
switch (_that) {
case _Thumbnail() when $default != null:
return $default(_that.url);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Thumbnail implements Thumbnail {
  const _Thumbnail({required this.url});
  factory _Thumbnail.fromJson(Map<String, dynamic> json) => _$ThumbnailFromJson(json);

@override final  String url;

/// Create a copy of Thumbnail
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ThumbnailCopyWith<_Thumbnail> get copyWith => __$ThumbnailCopyWithImpl<_Thumbnail>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ThumbnailToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Thumbnail&&(identical(other.url, url) || other.url == url));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,url);

@override
String toString() {
  return 'Thumbnail(url: $url)';
}


}

/// @nodoc
abstract mixin class _$ThumbnailCopyWith<$Res> implements $ThumbnailCopyWith<$Res> {
  factory _$ThumbnailCopyWith(_Thumbnail value, $Res Function(_Thumbnail) _then) = __$ThumbnailCopyWithImpl;
@override @useResult
$Res call({
 String url
});




}
/// @nodoc
class __$ThumbnailCopyWithImpl<$Res>
    implements _$ThumbnailCopyWith<$Res> {
  __$ThumbnailCopyWithImpl(this._self, this._then);

  final _Thumbnail _self;
  final $Res Function(_Thumbnail) _then;

/// Create a copy of Thumbnail
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? url = null,}) {
  return _then(_Thumbnail(
url: null == url ? _self.url : url // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
