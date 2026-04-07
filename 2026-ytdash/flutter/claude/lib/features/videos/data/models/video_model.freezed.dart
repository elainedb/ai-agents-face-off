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
mixin _$VideoModel {

 String get id; String get title; String get channelTitle; String get thumbnailUrl; String get publishedAt; List<String> get tags; String? get city; String? get country; double? get latitude; double? get longitude; String? get recordingDate;
/// Create a copy of VideoModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$VideoModelCopyWith<VideoModel> get copyWith => _$VideoModelCopyWithImpl<VideoModel>(this as VideoModel, _$identity);

  /// Serializes this VideoModel to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is VideoModel&&(identical(other.id, id) || other.id == id)&&(identical(other.title, title) || other.title == title)&&(identical(other.channelTitle, channelTitle) || other.channelTitle == channelTitle)&&(identical(other.thumbnailUrl, thumbnailUrl) || other.thumbnailUrl == thumbnailUrl)&&(identical(other.publishedAt, publishedAt) || other.publishedAt == publishedAt)&&const DeepCollectionEquality().equals(other.tags, tags)&&(identical(other.city, city) || other.city == city)&&(identical(other.country, country) || other.country == country)&&(identical(other.latitude, latitude) || other.latitude == latitude)&&(identical(other.longitude, longitude) || other.longitude == longitude)&&(identical(other.recordingDate, recordingDate) || other.recordingDate == recordingDate));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,title,channelTitle,thumbnailUrl,publishedAt,const DeepCollectionEquality().hash(tags),city,country,latitude,longitude,recordingDate);

@override
String toString() {
  return 'VideoModel(id: $id, title: $title, channelTitle: $channelTitle, thumbnailUrl: $thumbnailUrl, publishedAt: $publishedAt, tags: $tags, city: $city, country: $country, latitude: $latitude, longitude: $longitude, recordingDate: $recordingDate)';
}


}

/// @nodoc
abstract mixin class $VideoModelCopyWith<$Res>  {
  factory $VideoModelCopyWith(VideoModel value, $Res Function(VideoModel) _then) = _$VideoModelCopyWithImpl;
@useResult
$Res call({
 String id, String title, String channelTitle, String thumbnailUrl, String publishedAt, List<String> tags, String? city, String? country, double? latitude, double? longitude, String? recordingDate
});




}
/// @nodoc
class _$VideoModelCopyWithImpl<$Res>
    implements $VideoModelCopyWith<$Res> {
  _$VideoModelCopyWithImpl(this._self, this._then);

  final VideoModel _self;
  final $Res Function(VideoModel) _then;

/// Create a copy of VideoModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? title = null,Object? channelTitle = null,Object? thumbnailUrl = null,Object? publishedAt = null,Object? tags = null,Object? city = freezed,Object? country = freezed,Object? latitude = freezed,Object? longitude = freezed,Object? recordingDate = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,channelTitle: null == channelTitle ? _self.channelTitle : channelTitle // ignore: cast_nullable_to_non_nullable
as String,thumbnailUrl: null == thumbnailUrl ? _self.thumbnailUrl : thumbnailUrl // ignore: cast_nullable_to_non_nullable
as String,publishedAt: null == publishedAt ? _self.publishedAt : publishedAt // ignore: cast_nullable_to_non_nullable
as String,tags: null == tags ? _self.tags : tags // ignore: cast_nullable_to_non_nullable
as List<String>,city: freezed == city ? _self.city : city // ignore: cast_nullable_to_non_nullable
as String?,country: freezed == country ? _self.country : country // ignore: cast_nullable_to_non_nullable
as String?,latitude: freezed == latitude ? _self.latitude : latitude // ignore: cast_nullable_to_non_nullable
as double?,longitude: freezed == longitude ? _self.longitude : longitude // ignore: cast_nullable_to_non_nullable
as double?,recordingDate: freezed == recordingDate ? _self.recordingDate : recordingDate // ignore: cast_nullable_to_non_nullable
as String?,
  ));
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String title,  String channelTitle,  String thumbnailUrl,  String publishedAt,  List<String> tags,  String? city,  String? country,  double? latitude,  double? longitude,  String? recordingDate)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _VideoModel() when $default != null:
return $default(_that.id,_that.title,_that.channelTitle,_that.thumbnailUrl,_that.publishedAt,_that.tags,_that.city,_that.country,_that.latitude,_that.longitude,_that.recordingDate);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String title,  String channelTitle,  String thumbnailUrl,  String publishedAt,  List<String> tags,  String? city,  String? country,  double? latitude,  double? longitude,  String? recordingDate)  $default,) {final _that = this;
switch (_that) {
case _VideoModel():
return $default(_that.id,_that.title,_that.channelTitle,_that.thumbnailUrl,_that.publishedAt,_that.tags,_that.city,_that.country,_that.latitude,_that.longitude,_that.recordingDate);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String title,  String channelTitle,  String thumbnailUrl,  String publishedAt,  List<String> tags,  String? city,  String? country,  double? latitude,  double? longitude,  String? recordingDate)?  $default,) {final _that = this;
switch (_that) {
case _VideoModel() when $default != null:
return $default(_that.id,_that.title,_that.channelTitle,_that.thumbnailUrl,_that.publishedAt,_that.tags,_that.city,_that.country,_that.latitude,_that.longitude,_that.recordingDate);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _VideoModel extends VideoModel {
  const _VideoModel({required this.id, required this.title, required this.channelTitle, required this.thumbnailUrl, required this.publishedAt, final  List<String> tags = const [], this.city, this.country, this.latitude, this.longitude, this.recordingDate}): _tags = tags,super._();
  factory _VideoModel.fromJson(Map<String, dynamic> json) => _$VideoModelFromJson(json);

@override final  String id;
@override final  String title;
@override final  String channelTitle;
@override final  String thumbnailUrl;
@override final  String publishedAt;
 final  List<String> _tags;
@override@JsonKey() List<String> get tags {
  if (_tags is EqualUnmodifiableListView) return _tags;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_tags);
}

@override final  String? city;
@override final  String? country;
@override final  double? latitude;
@override final  double? longitude;
@override final  String? recordingDate;

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
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _VideoModel&&(identical(other.id, id) || other.id == id)&&(identical(other.title, title) || other.title == title)&&(identical(other.channelTitle, channelTitle) || other.channelTitle == channelTitle)&&(identical(other.thumbnailUrl, thumbnailUrl) || other.thumbnailUrl == thumbnailUrl)&&(identical(other.publishedAt, publishedAt) || other.publishedAt == publishedAt)&&const DeepCollectionEquality().equals(other._tags, _tags)&&(identical(other.city, city) || other.city == city)&&(identical(other.country, country) || other.country == country)&&(identical(other.latitude, latitude) || other.latitude == latitude)&&(identical(other.longitude, longitude) || other.longitude == longitude)&&(identical(other.recordingDate, recordingDate) || other.recordingDate == recordingDate));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,title,channelTitle,thumbnailUrl,publishedAt,const DeepCollectionEquality().hash(_tags),city,country,latitude,longitude,recordingDate);

@override
String toString() {
  return 'VideoModel(id: $id, title: $title, channelTitle: $channelTitle, thumbnailUrl: $thumbnailUrl, publishedAt: $publishedAt, tags: $tags, city: $city, country: $country, latitude: $latitude, longitude: $longitude, recordingDate: $recordingDate)';
}


}

/// @nodoc
abstract mixin class _$VideoModelCopyWith<$Res> implements $VideoModelCopyWith<$Res> {
  factory _$VideoModelCopyWith(_VideoModel value, $Res Function(_VideoModel) _then) = __$VideoModelCopyWithImpl;
@override @useResult
$Res call({
 String id, String title, String channelTitle, String thumbnailUrl, String publishedAt, List<String> tags, String? city, String? country, double? latitude, double? longitude, String? recordingDate
});




}
/// @nodoc
class __$VideoModelCopyWithImpl<$Res>
    implements _$VideoModelCopyWith<$Res> {
  __$VideoModelCopyWithImpl(this._self, this._then);

  final _VideoModel _self;
  final $Res Function(_VideoModel) _then;

/// Create a copy of VideoModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? title = null,Object? channelTitle = null,Object? thumbnailUrl = null,Object? publishedAt = null,Object? tags = null,Object? city = freezed,Object? country = freezed,Object? latitude = freezed,Object? longitude = freezed,Object? recordingDate = freezed,}) {
  return _then(_VideoModel(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,channelTitle: null == channelTitle ? _self.channelTitle : channelTitle // ignore: cast_nullable_to_non_nullable
as String,thumbnailUrl: null == thumbnailUrl ? _self.thumbnailUrl : thumbnailUrl // ignore: cast_nullable_to_non_nullable
as String,publishedAt: null == publishedAt ? _self.publishedAt : publishedAt // ignore: cast_nullable_to_non_nullable
as String,tags: null == tags ? _self._tags : tags // ignore: cast_nullable_to_non_nullable
as List<String>,city: freezed == city ? _self.city : city // ignore: cast_nullable_to_non_nullable
as String?,country: freezed == country ? _self.country : country // ignore: cast_nullable_to_non_nullable
as String?,latitude: freezed == latitude ? _self.latitude : latitude // ignore: cast_nullable_to_non_nullable
as double?,longitude: freezed == longitude ? _self.longitude : longitude // ignore: cast_nullable_to_non_nullable
as double?,recordingDate: freezed == recordingDate ? _self.recordingDate : recordingDate // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
