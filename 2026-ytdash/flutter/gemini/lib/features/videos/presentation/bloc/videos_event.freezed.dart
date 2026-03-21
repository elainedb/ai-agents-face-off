// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'videos_event.dart';

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
return clearFilters(_that);case _:
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
return clearFilters();case _:
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




// dart format on
