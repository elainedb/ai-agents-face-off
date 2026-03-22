// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'auth_event.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$AuthEvent {





@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AuthEvent);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'AuthEvent()';
}


}

/// @nodoc
class $AuthEventCopyWith<$Res>  {
$AuthEventCopyWith(AuthEvent _, $Res Function(AuthEvent) __);
}


/// Adds pattern-matching-related methods to [AuthEvent].
extension AuthEventPatterns on AuthEvent {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( _SignInWithGoogle value)?  signInWithGoogle,TResult Function( _SignOut value)?  signOut,TResult Function( _CheckAuthStatus value)?  checkAuthStatus,required TResult orElse(),}){
final _that = this;
switch (_that) {
case _SignInWithGoogle() when signInWithGoogle != null:
return signInWithGoogle(_that);case _SignOut() when signOut != null:
return signOut(_that);case _CheckAuthStatus() when checkAuthStatus != null:
return checkAuthStatus(_that);case _:
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

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( _SignInWithGoogle value)  signInWithGoogle,required TResult Function( _SignOut value)  signOut,required TResult Function( _CheckAuthStatus value)  checkAuthStatus,}){
final _that = this;
switch (_that) {
case _SignInWithGoogle():
return signInWithGoogle(_that);case _SignOut():
return signOut(_that);case _CheckAuthStatus():
return checkAuthStatus(_that);case _:
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( _SignInWithGoogle value)?  signInWithGoogle,TResult? Function( _SignOut value)?  signOut,TResult? Function( _CheckAuthStatus value)?  checkAuthStatus,}){
final _that = this;
switch (_that) {
case _SignInWithGoogle() when signInWithGoogle != null:
return signInWithGoogle(_that);case _SignOut() when signOut != null:
return signOut(_that);case _CheckAuthStatus() when checkAuthStatus != null:
return checkAuthStatus(_that);case _:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function()?  signInWithGoogle,TResult Function()?  signOut,TResult Function()?  checkAuthStatus,required TResult orElse(),}) {final _that = this;
switch (_that) {
case _SignInWithGoogle() when signInWithGoogle != null:
return signInWithGoogle();case _SignOut() when signOut != null:
return signOut();case _CheckAuthStatus() when checkAuthStatus != null:
return checkAuthStatus();case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function()  signInWithGoogle,required TResult Function()  signOut,required TResult Function()  checkAuthStatus,}) {final _that = this;
switch (_that) {
case _SignInWithGoogle():
return signInWithGoogle();case _SignOut():
return signOut();case _CheckAuthStatus():
return checkAuthStatus();case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function()?  signInWithGoogle,TResult? Function()?  signOut,TResult? Function()?  checkAuthStatus,}) {final _that = this;
switch (_that) {
case _SignInWithGoogle() when signInWithGoogle != null:
return signInWithGoogle();case _SignOut() when signOut != null:
return signOut();case _CheckAuthStatus() when checkAuthStatus != null:
return checkAuthStatus();case _:
  return null;

}
}

}

/// @nodoc


class _SignInWithGoogle implements AuthEvent {
  const _SignInWithGoogle();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _SignInWithGoogle);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'AuthEvent.signInWithGoogle()';
}


}




/// @nodoc


class _SignOut implements AuthEvent {
  const _SignOut();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _SignOut);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'AuthEvent.signOut()';
}


}




/// @nodoc


class _CheckAuthStatus implements AuthEvent {
  const _CheckAuthStatus();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _CheckAuthStatus);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'AuthEvent.checkAuthStatus()';
}


}




// dart format on
