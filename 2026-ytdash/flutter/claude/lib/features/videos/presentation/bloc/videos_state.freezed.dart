// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'videos_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$VideosState {





@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is VideosState);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'VideosState()';
}


}

/// @nodoc
class $VideosStateCopyWith<$Res>  {
$VideosStateCopyWith(VideosState _, $Res Function(VideosState) __);
}


/// Adds pattern-matching-related methods to [VideosState].
extension VideosStatePatterns on VideosState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( VideosInitial value)?  initial,TResult Function( VideosLoading value)?  loading,TResult Function( VideosLoaded value)?  loaded,TResult Function( VideosError value)?  error,required TResult orElse(),}){
final _that = this;
switch (_that) {
case VideosInitial() when initial != null:
return initial(_that);case VideosLoading() when loading != null:
return loading(_that);case VideosLoaded() when loaded != null:
return loaded(_that);case VideosError() when error != null:
return error(_that);case _:
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

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( VideosInitial value)  initial,required TResult Function( VideosLoading value)  loading,required TResult Function( VideosLoaded value)  loaded,required TResult Function( VideosError value)  error,}){
final _that = this;
switch (_that) {
case VideosInitial():
return initial(_that);case VideosLoading():
return loading(_that);case VideosLoaded():
return loaded(_that);case VideosError():
return error(_that);}
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( VideosInitial value)?  initial,TResult? Function( VideosLoading value)?  loading,TResult? Function( VideosLoaded value)?  loaded,TResult? Function( VideosError value)?  error,}){
final _that = this;
switch (_that) {
case VideosInitial() when initial != null:
return initial(_that);case VideosLoading() when loading != null:
return loading(_that);case VideosLoaded() when loaded != null:
return loaded(_that);case VideosError() when error != null:
return error(_that);case _:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function()?  initial,TResult Function()?  loading,TResult Function( List<Video> videos,  List<Video> filteredVideos,  String? selectedChannel,  String? selectedCountry,  SortBy sortBy,  SortOrder sortOrder,  bool isRefreshing)?  loaded,TResult Function( String message)?  error,required TResult orElse(),}) {final _that = this;
switch (_that) {
case VideosInitial() when initial != null:
return initial();case VideosLoading() when loading != null:
return loading();case VideosLoaded() when loaded != null:
return loaded(_that.videos,_that.filteredVideos,_that.selectedChannel,_that.selectedCountry,_that.sortBy,_that.sortOrder,_that.isRefreshing);case VideosError() when error != null:
return error(_that.message);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function()  initial,required TResult Function()  loading,required TResult Function( List<Video> videos,  List<Video> filteredVideos,  String? selectedChannel,  String? selectedCountry,  SortBy sortBy,  SortOrder sortOrder,  bool isRefreshing)  loaded,required TResult Function( String message)  error,}) {final _that = this;
switch (_that) {
case VideosInitial():
return initial();case VideosLoading():
return loading();case VideosLoaded():
return loaded(_that.videos,_that.filteredVideos,_that.selectedChannel,_that.selectedCountry,_that.sortBy,_that.sortOrder,_that.isRefreshing);case VideosError():
return error(_that.message);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function()?  initial,TResult? Function()?  loading,TResult? Function( List<Video> videos,  List<Video> filteredVideos,  String? selectedChannel,  String? selectedCountry,  SortBy sortBy,  SortOrder sortOrder,  bool isRefreshing)?  loaded,TResult? Function( String message)?  error,}) {final _that = this;
switch (_that) {
case VideosInitial() when initial != null:
return initial();case VideosLoading() when loading != null:
return loading();case VideosLoaded() when loaded != null:
return loaded(_that.videos,_that.filteredVideos,_that.selectedChannel,_that.selectedCountry,_that.sortBy,_that.sortOrder,_that.isRefreshing);case VideosError() when error != null:
return error(_that.message);case _:
  return null;

}
}

}

/// @nodoc


class VideosInitial implements VideosState {
  const VideosInitial();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is VideosInitial);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'VideosState.initial()';
}


}




/// @nodoc


class VideosLoading implements VideosState {
  const VideosLoading();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is VideosLoading);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'VideosState.loading()';
}


}




/// @nodoc


class VideosLoaded implements VideosState {
  const VideosLoaded({required final  List<Video> videos, required final  List<Video> filteredVideos, this.selectedChannel, this.selectedCountry, required this.sortBy, required this.sortOrder, this.isRefreshing = false}): _videos = videos,_filteredVideos = filteredVideos;
  

 final  List<Video> _videos;
 List<Video> get videos {
  if (_videos is EqualUnmodifiableListView) return _videos;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_videos);
}

 final  List<Video> _filteredVideos;
 List<Video> get filteredVideos {
  if (_filteredVideos is EqualUnmodifiableListView) return _filteredVideos;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_filteredVideos);
}

 final  String? selectedChannel;
 final  String? selectedCountry;
 final  SortBy sortBy;
 final  SortOrder sortOrder;
@JsonKey() final  bool isRefreshing;

/// Create a copy of VideosState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$VideosLoadedCopyWith<VideosLoaded> get copyWith => _$VideosLoadedCopyWithImpl<VideosLoaded>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is VideosLoaded&&const DeepCollectionEquality().equals(other._videos, _videos)&&const DeepCollectionEquality().equals(other._filteredVideos, _filteredVideos)&&(identical(other.selectedChannel, selectedChannel) || other.selectedChannel == selectedChannel)&&(identical(other.selectedCountry, selectedCountry) || other.selectedCountry == selectedCountry)&&(identical(other.sortBy, sortBy) || other.sortBy == sortBy)&&(identical(other.sortOrder, sortOrder) || other.sortOrder == sortOrder)&&(identical(other.isRefreshing, isRefreshing) || other.isRefreshing == isRefreshing));
}


@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(_videos),const DeepCollectionEquality().hash(_filteredVideos),selectedChannel,selectedCountry,sortBy,sortOrder,isRefreshing);

@override
String toString() {
  return 'VideosState.loaded(videos: $videos, filteredVideos: $filteredVideos, selectedChannel: $selectedChannel, selectedCountry: $selectedCountry, sortBy: $sortBy, sortOrder: $sortOrder, isRefreshing: $isRefreshing)';
}


}

/// @nodoc
abstract mixin class $VideosLoadedCopyWith<$Res> implements $VideosStateCopyWith<$Res> {
  factory $VideosLoadedCopyWith(VideosLoaded value, $Res Function(VideosLoaded) _then) = _$VideosLoadedCopyWithImpl;
@useResult
$Res call({
 List<Video> videos, List<Video> filteredVideos, String? selectedChannel, String? selectedCountry, SortBy sortBy, SortOrder sortOrder, bool isRefreshing
});




}
/// @nodoc
class _$VideosLoadedCopyWithImpl<$Res>
    implements $VideosLoadedCopyWith<$Res> {
  _$VideosLoadedCopyWithImpl(this._self, this._then);

  final VideosLoaded _self;
  final $Res Function(VideosLoaded) _then;

/// Create a copy of VideosState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? videos = null,Object? filteredVideos = null,Object? selectedChannel = freezed,Object? selectedCountry = freezed,Object? sortBy = null,Object? sortOrder = null,Object? isRefreshing = null,}) {
  return _then(VideosLoaded(
videos: null == videos ? _self._videos : videos // ignore: cast_nullable_to_non_nullable
as List<Video>,filteredVideos: null == filteredVideos ? _self._filteredVideos : filteredVideos // ignore: cast_nullable_to_non_nullable
as List<Video>,selectedChannel: freezed == selectedChannel ? _self.selectedChannel : selectedChannel // ignore: cast_nullable_to_non_nullable
as String?,selectedCountry: freezed == selectedCountry ? _self.selectedCountry : selectedCountry // ignore: cast_nullable_to_non_nullable
as String?,sortBy: null == sortBy ? _self.sortBy : sortBy // ignore: cast_nullable_to_non_nullable
as SortBy,sortOrder: null == sortOrder ? _self.sortOrder : sortOrder // ignore: cast_nullable_to_non_nullable
as SortOrder,isRefreshing: null == isRefreshing ? _self.isRefreshing : isRefreshing // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

/// @nodoc


class VideosError implements VideosState {
  const VideosError(this.message);
  

 final  String message;

/// Create a copy of VideosState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$VideosErrorCopyWith<VideosError> get copyWith => _$VideosErrorCopyWithImpl<VideosError>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is VideosError&&(identical(other.message, message) || other.message == message));
}


@override
int get hashCode => Object.hash(runtimeType,message);

@override
String toString() {
  return 'VideosState.error(message: $message)';
}


}

/// @nodoc
abstract mixin class $VideosErrorCopyWith<$Res> implements $VideosStateCopyWith<$Res> {
  factory $VideosErrorCopyWith(VideosError value, $Res Function(VideosError) _then) = _$VideosErrorCopyWithImpl;
@useResult
$Res call({
 String message
});




}
/// @nodoc
class _$VideosErrorCopyWithImpl<$Res>
    implements $VideosErrorCopyWith<$Res> {
  _$VideosErrorCopyWithImpl(this._self, this._then);

  final VideosError _self;
  final $Res Function(VideosError) _then;

/// Create a copy of VideosState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? message = null,}) {
  return _then(VideosError(
null == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
