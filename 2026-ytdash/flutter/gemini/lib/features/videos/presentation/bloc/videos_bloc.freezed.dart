// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'videos_bloc.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$VideosEvent {





@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is VideosEvent);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'VideosEvent()';
}


}

/// @nodoc
class $VideosEventCopyWith<$Res>  {
$VideosEventCopyWith(VideosEvent _, $Res Function(VideosEvent) __);
}


/// Adds pattern-matching-related methods to [VideosEvent].
extension VideosEventPatterns on VideosEvent {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( _LoadVideos value)?  loadVideos,TResult Function( _RefreshVideos value)?  refreshVideos,TResult Function( _FilterByChannel value)?  filterByChannel,TResult Function( _FilterByCountry value)?  filterByCountry,TResult Function( _SortVideos value)?  sortVideos,TResult Function( _ClearFilters value)?  clearFilters,required TResult orElse(),}){
final _that = this;
switch (_that) {
case _LoadVideos() when loadVideos != null:
return loadVideos(_that);case _RefreshVideos() when refreshVideos != null:
return refreshVideos(_that);case _FilterByChannel() when filterByChannel != null:
return filterByChannel(_that);case _FilterByCountry() when filterByCountry != null:
return filterByCountry(_that);case _SortVideos() when sortVideos != null:
return sortVideos(_that);case _ClearFilters() when clearFilters != null:
return clearFilters(_that);case _:
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

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( _LoadVideos value)  loadVideos,required TResult Function( _RefreshVideos value)  refreshVideos,required TResult Function( _FilterByChannel value)  filterByChannel,required TResult Function( _FilterByCountry value)  filterByCountry,required TResult Function( _SortVideos value)  sortVideos,required TResult Function( _ClearFilters value)  clearFilters,}){
final _that = this;
switch (_that) {
case _LoadVideos():
return loadVideos(_that);case _RefreshVideos():
return refreshVideos(_that);case _FilterByChannel():
return filterByChannel(_that);case _FilterByCountry():
return filterByCountry(_that);case _SortVideos():
return sortVideos(_that);case _ClearFilters():
return clearFilters(_that);}
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( _LoadVideos value)?  loadVideos,TResult? Function( _RefreshVideos value)?  refreshVideos,TResult? Function( _FilterByChannel value)?  filterByChannel,TResult? Function( _FilterByCountry value)?  filterByCountry,TResult? Function( _SortVideos value)?  sortVideos,TResult? Function( _ClearFilters value)?  clearFilters,}){
final _that = this;
switch (_that) {
case _LoadVideos() when loadVideos != null:
return loadVideos(_that);case _RefreshVideos() when refreshVideos != null:
return refreshVideos(_that);case _FilterByChannel() when filterByChannel != null:
return filterByChannel(_that);case _FilterByCountry() when filterByCountry != null:
return filterByCountry(_that);case _SortVideos() when sortVideos != null:
return sortVideos(_that);case _ClearFilters() when clearFilters != null:
return clearFilters(_that);case _:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function()?  loadVideos,TResult Function()?  refreshVideos,TResult Function( String? channelName)?  filterByChannel,TResult Function( String? country)?  filterByCountry,TResult Function( SortBy sortBy,  SortOrder sortOrder)?  sortVideos,TResult Function()?  clearFilters,required TResult orElse(),}) {final _that = this;
switch (_that) {
case _LoadVideos() when loadVideos != null:
return loadVideos();case _RefreshVideos() when refreshVideos != null:
return refreshVideos();case _FilterByChannel() when filterByChannel != null:
return filterByChannel(_that.channelName);case _FilterByCountry() when filterByCountry != null:
return filterByCountry(_that.country);case _SortVideos() when sortVideos != null:
return sortVideos(_that.sortBy,_that.sortOrder);case _ClearFilters() when clearFilters != null:
return clearFilters();case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function()  loadVideos,required TResult Function()  refreshVideos,required TResult Function( String? channelName)  filterByChannel,required TResult Function( String? country)  filterByCountry,required TResult Function( SortBy sortBy,  SortOrder sortOrder)  sortVideos,required TResult Function()  clearFilters,}) {final _that = this;
switch (_that) {
case _LoadVideos():
return loadVideos();case _RefreshVideos():
return refreshVideos();case _FilterByChannel():
return filterByChannel(_that.channelName);case _FilterByCountry():
return filterByCountry(_that.country);case _SortVideos():
return sortVideos(_that.sortBy,_that.sortOrder);case _ClearFilters():
return clearFilters();}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function()?  loadVideos,TResult? Function()?  refreshVideos,TResult? Function( String? channelName)?  filterByChannel,TResult? Function( String? country)?  filterByCountry,TResult? Function( SortBy sortBy,  SortOrder sortOrder)?  sortVideos,TResult? Function()?  clearFilters,}) {final _that = this;
switch (_that) {
case _LoadVideos() when loadVideos != null:
return loadVideos();case _RefreshVideos() when refreshVideos != null:
return refreshVideos();case _FilterByChannel() when filterByChannel != null:
return filterByChannel(_that.channelName);case _FilterByCountry() when filterByCountry != null:
return filterByCountry(_that.country);case _SortVideos() when sortVideos != null:
return sortVideos(_that.sortBy,_that.sortOrder);case _ClearFilters() when clearFilters != null:
return clearFilters();case _:
  return null;

}
}

}

/// @nodoc


class _LoadVideos implements VideosEvent {
  const _LoadVideos();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _LoadVideos);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'VideosEvent.loadVideos()';
}


}




/// @nodoc


class _RefreshVideos implements VideosEvent {
  const _RefreshVideos();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _RefreshVideos);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'VideosEvent.refreshVideos()';
}


}




/// @nodoc


class _FilterByChannel implements VideosEvent {
  const _FilterByChannel(this.channelName);
  

 final  String? channelName;

/// Create a copy of VideosEvent
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$FilterByChannelCopyWith<_FilterByChannel> get copyWith => __$FilterByChannelCopyWithImpl<_FilterByChannel>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _FilterByChannel&&(identical(other.channelName, channelName) || other.channelName == channelName));
}


@override
int get hashCode => Object.hash(runtimeType,channelName);

@override
String toString() {
  return 'VideosEvent.filterByChannel(channelName: $channelName)';
}


}

/// @nodoc
abstract mixin class _$FilterByChannelCopyWith<$Res> implements $VideosEventCopyWith<$Res> {
  factory _$FilterByChannelCopyWith(_FilterByChannel value, $Res Function(_FilterByChannel) _then) = __$FilterByChannelCopyWithImpl;
@useResult
$Res call({
 String? channelName
});




}
/// @nodoc
class __$FilterByChannelCopyWithImpl<$Res>
    implements _$FilterByChannelCopyWith<$Res> {
  __$FilterByChannelCopyWithImpl(this._self, this._then);

  final _FilterByChannel _self;
  final $Res Function(_FilterByChannel) _then;

/// Create a copy of VideosEvent
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? channelName = freezed,}) {
  return _then(_FilterByChannel(
freezed == channelName ? _self.channelName : channelName // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

/// @nodoc


class _FilterByCountry implements VideosEvent {
  const _FilterByCountry(this.country);
  

 final  String? country;

/// Create a copy of VideosEvent
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$FilterByCountryCopyWith<_FilterByCountry> get copyWith => __$FilterByCountryCopyWithImpl<_FilterByCountry>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _FilterByCountry&&(identical(other.country, country) || other.country == country));
}


@override
int get hashCode => Object.hash(runtimeType,country);

@override
String toString() {
  return 'VideosEvent.filterByCountry(country: $country)';
}


}

/// @nodoc
abstract mixin class _$FilterByCountryCopyWith<$Res> implements $VideosEventCopyWith<$Res> {
  factory _$FilterByCountryCopyWith(_FilterByCountry value, $Res Function(_FilterByCountry) _then) = __$FilterByCountryCopyWithImpl;
@useResult
$Res call({
 String? country
});




}
/// @nodoc
class __$FilterByCountryCopyWithImpl<$Res>
    implements _$FilterByCountryCopyWith<$Res> {
  __$FilterByCountryCopyWithImpl(this._self, this._then);

  final _FilterByCountry _self;
  final $Res Function(_FilterByCountry) _then;

/// Create a copy of VideosEvent
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? country = freezed,}) {
  return _then(_FilterByCountry(
freezed == country ? _self.country : country // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

/// @nodoc


class _SortVideos implements VideosEvent {
  const _SortVideos(this.sortBy, this.sortOrder);
  

 final  SortBy sortBy;
 final  SortOrder sortOrder;

/// Create a copy of VideosEvent
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SortVideosCopyWith<_SortVideos> get copyWith => __$SortVideosCopyWithImpl<_SortVideos>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _SortVideos&&(identical(other.sortBy, sortBy) || other.sortBy == sortBy)&&(identical(other.sortOrder, sortOrder) || other.sortOrder == sortOrder));
}


@override
int get hashCode => Object.hash(runtimeType,sortBy,sortOrder);

@override
String toString() {
  return 'VideosEvent.sortVideos(sortBy: $sortBy, sortOrder: $sortOrder)';
}


}

/// @nodoc
abstract mixin class _$SortVideosCopyWith<$Res> implements $VideosEventCopyWith<$Res> {
  factory _$SortVideosCopyWith(_SortVideos value, $Res Function(_SortVideos) _then) = __$SortVideosCopyWithImpl;
@useResult
$Res call({
 SortBy sortBy, SortOrder sortOrder
});




}
/// @nodoc
class __$SortVideosCopyWithImpl<$Res>
    implements _$SortVideosCopyWith<$Res> {
  __$SortVideosCopyWithImpl(this._self, this._then);

  final _SortVideos _self;
  final $Res Function(_SortVideos) _then;

/// Create a copy of VideosEvent
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? sortBy = null,Object? sortOrder = null,}) {
  return _then(_SortVideos(
null == sortBy ? _self.sortBy : sortBy // ignore: cast_nullable_to_non_nullable
as SortBy,null == sortOrder ? _self.sortOrder : sortOrder // ignore: cast_nullable_to_non_nullable
as SortOrder,
  ));
}


}

/// @nodoc


class _ClearFilters implements VideosEvent {
  const _ClearFilters();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ClearFilters);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'VideosEvent.clearFilters()';
}


}




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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( _Initial value)?  initial,TResult Function( _Loading value)?  loading,TResult Function( VideosLoaded value)?  loaded,TResult Function( _Error value)?  error,required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Initial() when initial != null:
return initial(_that);case _Loading() when loading != null:
return loading(_that);case VideosLoaded() when loaded != null:
return loaded(_that);case _Error() when error != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( _Initial value)  initial,required TResult Function( _Loading value)  loading,required TResult Function( VideosLoaded value)  loaded,required TResult Function( _Error value)  error,}){
final _that = this;
switch (_that) {
case _Initial():
return initial(_that);case _Loading():
return loading(_that);case VideosLoaded():
return loaded(_that);case _Error():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( _Initial value)?  initial,TResult? Function( _Loading value)?  loading,TResult? Function( VideosLoaded value)?  loaded,TResult? Function( _Error value)?  error,}){
final _that = this;
switch (_that) {
case _Initial() when initial != null:
return initial(_that);case _Loading() when loading != null:
return loading(_that);case VideosLoaded() when loaded != null:
return loaded(_that);case _Error() when error != null:
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
case _Initial() when initial != null:
return initial();case _Loading() when loading != null:
return loading();case VideosLoaded() when loaded != null:
return loaded(_that.videos,_that.filteredVideos,_that.selectedChannel,_that.selectedCountry,_that.sortBy,_that.sortOrder,_that.isRefreshing);case _Error() when error != null:
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
case _Initial():
return initial();case _Loading():
return loading();case VideosLoaded():
return loaded(_that.videos,_that.filteredVideos,_that.selectedChannel,_that.selectedCountry,_that.sortBy,_that.sortOrder,_that.isRefreshing);case _Error():
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
case _Initial() when initial != null:
return initial();case _Loading() when loading != null:
return loading();case VideosLoaded() when loaded != null:
return loaded(_that.videos,_that.filteredVideos,_that.selectedChannel,_that.selectedCountry,_that.sortBy,_that.sortOrder,_that.isRefreshing);case _Error() when error != null:
return error(_that.message);case _:
  return null;

}
}

}

/// @nodoc


class _Initial implements VideosState {
  const _Initial();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Initial);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'VideosState.initial()';
}


}




/// @nodoc


class _Loading implements VideosState {
  const _Loading();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Loading);
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
  const VideosLoaded({required final  List<Video> videos, required final  List<Video> filteredVideos, this.selectedChannel, this.selectedCountry, this.sortBy = SortBy.publishedDate, this.sortOrder = SortOrder.descending, this.isRefreshing = false}): _videos = videos,_filteredVideos = filteredVideos;
  

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
@JsonKey() final  SortBy sortBy;
@JsonKey() final  SortOrder sortOrder;
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


class _Error implements VideosState {
  const _Error(this.message);
  

 final  String message;

/// Create a copy of VideosState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ErrorCopyWith<_Error> get copyWith => __$ErrorCopyWithImpl<_Error>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Error&&(identical(other.message, message) || other.message == message));
}


@override
int get hashCode => Object.hash(runtimeType,message);

@override
String toString() {
  return 'VideosState.error(message: $message)';
}


}

/// @nodoc
abstract mixin class _$ErrorCopyWith<$Res> implements $VideosStateCopyWith<$Res> {
  factory _$ErrorCopyWith(_Error value, $Res Function(_Error) _then) = __$ErrorCopyWithImpl;
@useResult
$Res call({
 String message
});




}
/// @nodoc
class __$ErrorCopyWithImpl<$Res>
    implements _$ErrorCopyWith<$Res> {
  __$ErrorCopyWithImpl(this._self, this._then);

  final _Error _self;
  final $Res Function(_Error) _then;

/// Create a copy of VideosState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? message = null,}) {
  return _then(_Error(
null == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
