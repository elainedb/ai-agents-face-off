// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'failures.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$Failure {

 String get message;
/// Create a copy of Failure
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$FailureCopyWith<Failure> get copyWith => _$FailureCopyWithImpl<Failure>(this as Failure, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Failure&&(identical(other.message, message) || other.message == message));
}


@override
int get hashCode => Object.hash(runtimeType,message);

@override
String toString() {
  return 'Failure(message: $message)';
}


}

/// @nodoc
abstract mixin class $FailureCopyWith<$Res>  {
  factory $FailureCopyWith(Failure value, $Res Function(Failure) _then) = _$FailureCopyWithImpl;
@useResult
$Res call({
 String message
});




}
/// @nodoc
class _$FailureCopyWithImpl<$Res>
    implements $FailureCopyWith<$Res> {
  _$FailureCopyWithImpl(this._self, this._then);

  final Failure _self;
  final $Res Function(Failure) _then;

/// Create a copy of Failure
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? message = null,}) {
  return _then(_self.copyWith(
message: null == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [Failure].
extension FailurePatterns on Failure {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( _Server value)?  server,TResult Function( _Cache value)?  cache,TResult Function( _Network value)?  network,TResult Function( _Auth value)?  auth,TResult Function( _Validation value)?  validation,TResult Function( _Unexpected value)?  unexpected,required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Server() when server != null:
return server(_that);case _Cache() when cache != null:
return cache(_that);case _Network() when network != null:
return network(_that);case _Auth() when auth != null:
return auth(_that);case _Validation() when validation != null:
return validation(_that);case _Unexpected() when unexpected != null:
return unexpected(_that);case _:
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

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( _Server value)  server,required TResult Function( _Cache value)  cache,required TResult Function( _Network value)  network,required TResult Function( _Auth value)  auth,required TResult Function( _Validation value)  validation,required TResult Function( _Unexpected value)  unexpected,}){
final _that = this;
switch (_that) {
case _Server():
return server(_that);case _Cache():
return cache(_that);case _Network():
return network(_that);case _Auth():
return auth(_that);case _Validation():
return validation(_that);case _Unexpected():
return unexpected(_that);case _:
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( _Server value)?  server,TResult? Function( _Cache value)?  cache,TResult? Function( _Network value)?  network,TResult? Function( _Auth value)?  auth,TResult? Function( _Validation value)?  validation,TResult? Function( _Unexpected value)?  unexpected,}){
final _that = this;
switch (_that) {
case _Server() when server != null:
return server(_that);case _Cache() when cache != null:
return cache(_that);case _Network() when network != null:
return network(_that);case _Auth() when auth != null:
return auth(_that);case _Validation() when validation != null:
return validation(_that);case _Unexpected() when unexpected != null:
return unexpected(_that);case _:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function( String message)?  server,TResult Function( String message)?  cache,TResult Function( String message)?  network,TResult Function( String message)?  auth,TResult Function( String message)?  validation,TResult Function( String message)?  unexpected,required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Server() when server != null:
return server(_that.message);case _Cache() when cache != null:
return cache(_that.message);case _Network() when network != null:
return network(_that.message);case _Auth() when auth != null:
return auth(_that.message);case _Validation() when validation != null:
return validation(_that.message);case _Unexpected() when unexpected != null:
return unexpected(_that.message);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function( String message)  server,required TResult Function( String message)  cache,required TResult Function( String message)  network,required TResult Function( String message)  auth,required TResult Function( String message)  validation,required TResult Function( String message)  unexpected,}) {final _that = this;
switch (_that) {
case _Server():
return server(_that.message);case _Cache():
return cache(_that.message);case _Network():
return network(_that.message);case _Auth():
return auth(_that.message);case _Validation():
return validation(_that.message);case _Unexpected():
return unexpected(_that.message);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function( String message)?  server,TResult? Function( String message)?  cache,TResult? Function( String message)?  network,TResult? Function( String message)?  auth,TResult? Function( String message)?  validation,TResult? Function( String message)?  unexpected,}) {final _that = this;
switch (_that) {
case _Server() when server != null:
return server(_that.message);case _Cache() when cache != null:
return cache(_that.message);case _Network() when network != null:
return network(_that.message);case _Auth() when auth != null:
return auth(_that.message);case _Validation() when validation != null:
return validation(_that.message);case _Unexpected() when unexpected != null:
return unexpected(_that.message);case _:
  return null;

}
}

}

/// @nodoc


class _Server extends Failure {
  const _Server(this.message): super._();
  

@override final  String message;

/// Create a copy of Failure
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ServerCopyWith<_Server> get copyWith => __$ServerCopyWithImpl<_Server>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Server&&(identical(other.message, message) || other.message == message));
}


@override
int get hashCode => Object.hash(runtimeType,message);

@override
String toString() {
  return 'Failure.server(message: $message)';
}


}

/// @nodoc
abstract mixin class _$ServerCopyWith<$Res> implements $FailureCopyWith<$Res> {
  factory _$ServerCopyWith(_Server value, $Res Function(_Server) _then) = __$ServerCopyWithImpl;
@override @useResult
$Res call({
 String message
});




}
/// @nodoc
class __$ServerCopyWithImpl<$Res>
    implements _$ServerCopyWith<$Res> {
  __$ServerCopyWithImpl(this._self, this._then);

  final _Server _self;
  final $Res Function(_Server) _then;

/// Create a copy of Failure
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? message = null,}) {
  return _then(_Server(
null == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

/// @nodoc


class _Cache extends Failure {
  const _Cache(this.message): super._();
  

@override final  String message;

/// Create a copy of Failure
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CacheCopyWith<_Cache> get copyWith => __$CacheCopyWithImpl<_Cache>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Cache&&(identical(other.message, message) || other.message == message));
}


@override
int get hashCode => Object.hash(runtimeType,message);

@override
String toString() {
  return 'Failure.cache(message: $message)';
}


}

/// @nodoc
abstract mixin class _$CacheCopyWith<$Res> implements $FailureCopyWith<$Res> {
  factory _$CacheCopyWith(_Cache value, $Res Function(_Cache) _then) = __$CacheCopyWithImpl;
@override @useResult
$Res call({
 String message
});




}
/// @nodoc
class __$CacheCopyWithImpl<$Res>
    implements _$CacheCopyWith<$Res> {
  __$CacheCopyWithImpl(this._self, this._then);

  final _Cache _self;
  final $Res Function(_Cache) _then;

/// Create a copy of Failure
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? message = null,}) {
  return _then(_Cache(
null == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

/// @nodoc


class _Network extends Failure {
  const _Network(this.message): super._();
  

@override final  String message;

/// Create a copy of Failure
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$NetworkCopyWith<_Network> get copyWith => __$NetworkCopyWithImpl<_Network>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Network&&(identical(other.message, message) || other.message == message));
}


@override
int get hashCode => Object.hash(runtimeType,message);

@override
String toString() {
  return 'Failure.network(message: $message)';
}


}

/// @nodoc
abstract mixin class _$NetworkCopyWith<$Res> implements $FailureCopyWith<$Res> {
  factory _$NetworkCopyWith(_Network value, $Res Function(_Network) _then) = __$NetworkCopyWithImpl;
@override @useResult
$Res call({
 String message
});




}
/// @nodoc
class __$NetworkCopyWithImpl<$Res>
    implements _$NetworkCopyWith<$Res> {
  __$NetworkCopyWithImpl(this._self, this._then);

  final _Network _self;
  final $Res Function(_Network) _then;

/// Create a copy of Failure
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? message = null,}) {
  return _then(_Network(
null == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

/// @nodoc


class _Auth extends Failure {
  const _Auth(this.message): super._();
  

@override final  String message;

/// Create a copy of Failure
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$AuthCopyWith<_Auth> get copyWith => __$AuthCopyWithImpl<_Auth>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Auth&&(identical(other.message, message) || other.message == message));
}


@override
int get hashCode => Object.hash(runtimeType,message);

@override
String toString() {
  return 'Failure.auth(message: $message)';
}


}

/// @nodoc
abstract mixin class _$AuthCopyWith<$Res> implements $FailureCopyWith<$Res> {
  factory _$AuthCopyWith(_Auth value, $Res Function(_Auth) _then) = __$AuthCopyWithImpl;
@override @useResult
$Res call({
 String message
});




}
/// @nodoc
class __$AuthCopyWithImpl<$Res>
    implements _$AuthCopyWith<$Res> {
  __$AuthCopyWithImpl(this._self, this._then);

  final _Auth _self;
  final $Res Function(_Auth) _then;

/// Create a copy of Failure
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? message = null,}) {
  return _then(_Auth(
null == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

/// @nodoc


class _Validation extends Failure {
  const _Validation(this.message): super._();
  

@override final  String message;

/// Create a copy of Failure
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ValidationCopyWith<_Validation> get copyWith => __$ValidationCopyWithImpl<_Validation>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Validation&&(identical(other.message, message) || other.message == message));
}


@override
int get hashCode => Object.hash(runtimeType,message);

@override
String toString() {
  return 'Failure.validation(message: $message)';
}


}

/// @nodoc
abstract mixin class _$ValidationCopyWith<$Res> implements $FailureCopyWith<$Res> {
  factory _$ValidationCopyWith(_Validation value, $Res Function(_Validation) _then) = __$ValidationCopyWithImpl;
@override @useResult
$Res call({
 String message
});




}
/// @nodoc
class __$ValidationCopyWithImpl<$Res>
    implements _$ValidationCopyWith<$Res> {
  __$ValidationCopyWithImpl(this._self, this._then);

  final _Validation _self;
  final $Res Function(_Validation) _then;

/// Create a copy of Failure
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? message = null,}) {
  return _then(_Validation(
null == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

/// @nodoc


class _Unexpected extends Failure {
  const _Unexpected(this.message): super._();
  

@override final  String message;

/// Create a copy of Failure
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$UnexpectedCopyWith<_Unexpected> get copyWith => __$UnexpectedCopyWithImpl<_Unexpected>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Unexpected&&(identical(other.message, message) || other.message == message));
}


@override
int get hashCode => Object.hash(runtimeType,message);

@override
String toString() {
  return 'Failure.unexpected(message: $message)';
}


}

/// @nodoc
abstract mixin class _$UnexpectedCopyWith<$Res> implements $FailureCopyWith<$Res> {
  factory _$UnexpectedCopyWith(_Unexpected value, $Res Function(_Unexpected) _then) = __$UnexpectedCopyWithImpl;
@override @useResult
$Res call({
 String message
});




}
/// @nodoc
class __$UnexpectedCopyWithImpl<$Res>
    implements _$UnexpectedCopyWith<$Res> {
  __$UnexpectedCopyWithImpl(this._self, this._then);

  final _Unexpected _self;
  final $Res Function(_Unexpected) _then;

/// Create a copy of Failure
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? message = null,}) {
  return _then(_Unexpected(
null == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
