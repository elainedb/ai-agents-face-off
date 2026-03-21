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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( LoadVideos value)?  loadVideos,TResult Function( RefreshVideos value)?  refreshVideos,TResult Function( FilterByChannel value)?  filterByChannel,TResult Function( FilterByCountry value)?  filterByCountry,TResult Function( SortVideosEvent value)?  sortVideos,TResult Function( ClearFilters value)?  clearFilters,required TResult orElse(),}){
final _that = this;
switch (_that) {
case LoadVideos() when loadVideos != null:
return loadVideos(_that);case RefreshVideos() when refreshVideos != null:
return refreshVideos(_that);case FilterByChannel() when filterByChannel != null:
return filterByChannel(_that);case FilterByCountry() when filterByCountry != null:
return filterByCountry(_that);case SortVideosEvent() when sortVideos != null:
return sortVideos(_that);case ClearFilters() when clearFilters != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( LoadVideos value)  loadVideos,required TResult Function( RefreshVideos value)  refreshVideos,required TResult Function( FilterByChannel value)  filterByChannel,required TResult Function( FilterByCountry value)  filterByCountry,required TResult Function( SortVideosEvent value)  sortVideos,required TResult Function( ClearFilters value)  clearFilters,}){
final _that = this;
switch (_that) {
case LoadVideos():
return loadVideos(_that);case RefreshVideos():
return refreshVideos(_that);case FilterByChannel():
return filterByChannel(_that);case FilterByCountry():
return filterByCountry(_that);case SortVideosEvent():
return sortVideos(_that);case ClearFilters():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( LoadVideos value)?  loadVideos,TResult? Function( RefreshVideos value)?  refreshVideos,TResult? Function( FilterByChannel value)?  filterByChannel,TResult? Function( FilterByCountry value)?  filterByCountry,TResult? Function( SortVideosEvent value)?  sortVideos,TResult? Function( ClearFilters value)?  clearFilters,}){
final _that = this;
switch (_that) {
case LoadVideos() when loadVideos != null:
return loadVideos(_that);case RefreshVideos() when refreshVideos != null:
return refreshVideos(_that);case FilterByChannel() when filterByChannel != null:
return filterByChannel(_that);case FilterByCountry() when filterByCountry != null:
return filterByCountry(_that);case SortVideosEvent() when sortVideos != null:
return sortVideos(_that);case ClearFilters() when clearFilters != null:
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
case LoadVideos() when loadVideos != null:
return loadVideos();case RefreshVideos() when refreshVideos != null:
return refreshVideos();case FilterByChannel() when filterByChannel != null:
return filterByChannel(_that.channelName);case FilterByCountry() when filterByCountry != null:
return filterByCountry(_that.country);case SortVideosEvent() when sortVideos != null:
return sortVideos(_that.sortBy,_that.sortOrder);case ClearFilters() when clearFilters != null:
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
case LoadVideos():
return loadVideos();case RefreshVideos():
return refreshVideos();case FilterByChannel():
return filterByChannel(_that.channelName);case FilterByCountry():
return filterByCountry(_that.country);case SortVideosEvent():
return sortVideos(_that.sortBy,_that.sortOrder);case ClearFilters():
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
case LoadVideos() when loadVideos != null:
return loadVideos();case RefreshVideos() when refreshVideos != null:
return refreshVideos();case FilterByChannel() when filterByChannel != null:
return filterByChannel(_that.channelName);case FilterByCountry() when filterByCountry != null:
return filterByCountry(_that.country);case SortVideosEvent() when sortVideos != null:
return sortVideos(_that.sortBy,_that.sortOrder);case ClearFilters() when clearFilters != null:
return clearFilters();case _:
  return null;

}
}

}

/// @nodoc


class LoadVideos implements VideosEvent {
  const LoadVideos();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is LoadVideos);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'VideosEvent.loadVideos()';
}


}




/// @nodoc


class RefreshVideos implements VideosEvent {
  const RefreshVideos();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is RefreshVideos);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'VideosEvent.refreshVideos()';
}


}




/// @nodoc


class FilterByChannel implements VideosEvent {
  const FilterByChannel(this.channelName);
  

 final  String? channelName;

/// Create a copy of VideosEvent
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$FilterByChannelCopyWith<FilterByChannel> get copyWith => _$FilterByChannelCopyWithImpl<FilterByChannel>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is FilterByChannel&&(identical(other.channelName, channelName) || other.channelName == channelName));
}


@override
int get hashCode => Object.hash(runtimeType,channelName);

@override
String toString() {
  return 'VideosEvent.filterByChannel(channelName: $channelName)';
}


}

/// @nodoc
abstract mixin class $FilterByChannelCopyWith<$Res> implements $VideosEventCopyWith<$Res> {
  factory $FilterByChannelCopyWith(FilterByChannel value, $Res Function(FilterByChannel) _then) = _$FilterByChannelCopyWithImpl;
@useResult
$Res call({
 String? channelName
});




}
/// @nodoc
class _$FilterByChannelCopyWithImpl<$Res>
    implements $FilterByChannelCopyWith<$Res> {
  _$FilterByChannelCopyWithImpl(this._self, this._then);

  final FilterByChannel _self;
  final $Res Function(FilterByChannel) _then;

/// Create a copy of VideosEvent
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? channelName = freezed,}) {
  return _then(FilterByChannel(
freezed == channelName ? _self.channelName : channelName // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

/// @nodoc


class FilterByCountry implements VideosEvent {
  const FilterByCountry(this.country);
  

 final  String? country;

/// Create a copy of VideosEvent
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$FilterByCountryCopyWith<FilterByCountry> get copyWith => _$FilterByCountryCopyWithImpl<FilterByCountry>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is FilterByCountry&&(identical(other.country, country) || other.country == country));
}


@override
int get hashCode => Object.hash(runtimeType,country);

@override
String toString() {
  return 'VideosEvent.filterByCountry(country: $country)';
}


}

/// @nodoc
abstract mixin class $FilterByCountryCopyWith<$Res> implements $VideosEventCopyWith<$Res> {
  factory $FilterByCountryCopyWith(FilterByCountry value, $Res Function(FilterByCountry) _then) = _$FilterByCountryCopyWithImpl;
@useResult
$Res call({
 String? country
});




}
/// @nodoc
class _$FilterByCountryCopyWithImpl<$Res>
    implements $FilterByCountryCopyWith<$Res> {
  _$FilterByCountryCopyWithImpl(this._self, this._then);

  final FilterByCountry _self;
  final $Res Function(FilterByCountry) _then;

/// Create a copy of VideosEvent
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? country = freezed,}) {
  return _then(FilterByCountry(
freezed == country ? _self.country : country // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

/// @nodoc


class SortVideosEvent implements VideosEvent {
  const SortVideosEvent(this.sortBy, this.sortOrder);
  

 final  SortBy sortBy;
 final  SortOrder sortOrder;

/// Create a copy of VideosEvent
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SortVideosEventCopyWith<SortVideosEvent> get copyWith => _$SortVideosEventCopyWithImpl<SortVideosEvent>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SortVideosEvent&&(identical(other.sortBy, sortBy) || other.sortBy == sortBy)&&(identical(other.sortOrder, sortOrder) || other.sortOrder == sortOrder));
}


@override
int get hashCode => Object.hash(runtimeType,sortBy,sortOrder);

@override
String toString() {
  return 'VideosEvent.sortVideos(sortBy: $sortBy, sortOrder: $sortOrder)';
}


}

/// @nodoc
abstract mixin class $SortVideosEventCopyWith<$Res> implements $VideosEventCopyWith<$Res> {
  factory $SortVideosEventCopyWith(SortVideosEvent value, $Res Function(SortVideosEvent) _then) = _$SortVideosEventCopyWithImpl;
@useResult
$Res call({
 SortBy sortBy, SortOrder sortOrder
});




}
/// @nodoc
class _$SortVideosEventCopyWithImpl<$Res>
    implements $SortVideosEventCopyWith<$Res> {
  _$SortVideosEventCopyWithImpl(this._self, this._then);

  final SortVideosEvent _self;
  final $Res Function(SortVideosEvent) _then;

/// Create a copy of VideosEvent
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? sortBy = null,Object? sortOrder = null,}) {
  return _then(SortVideosEvent(
null == sortBy ? _self.sortBy : sortBy // ignore: cast_nullable_to_non_nullable
as SortBy,null == sortOrder ? _self.sortOrder : sortOrder // ignore: cast_nullable_to_non_nullable
as SortOrder,
  ));
}


}

/// @nodoc


class ClearFilters implements VideosEvent {
  const ClearFilters();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ClearFilters);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'VideosEvent.clearFilters()';
}


}




// dart format on
