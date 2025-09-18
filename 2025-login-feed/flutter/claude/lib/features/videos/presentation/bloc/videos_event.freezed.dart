// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'videos_event.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

/// @nodoc
mixin _$VideosEvent {
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() loadVideos,
    required TResult Function() refreshVideos,
  }) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? loadVideos,
    TResult? Function()? refreshVideos,
  }) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? loadVideos,
    TResult Function()? refreshVideos,
    required TResult orElse(),
  }) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(LoadVideos value) loadVideos,
    required TResult Function(RefreshVideos value) refreshVideos,
  }) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(LoadVideos value)? loadVideos,
    TResult? Function(RefreshVideos value)? refreshVideos,
  }) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(LoadVideos value)? loadVideos,
    TResult Function(RefreshVideos value)? refreshVideos,
    required TResult orElse(),
  }) => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $VideosEventCopyWith<$Res> {
  factory $VideosEventCopyWith(
    VideosEvent value,
    $Res Function(VideosEvent) then,
  ) = _$VideosEventCopyWithImpl<$Res, VideosEvent>;
}

/// @nodoc
class _$VideosEventCopyWithImpl<$Res, $Val extends VideosEvent>
    implements $VideosEventCopyWith<$Res> {
  _$VideosEventCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of VideosEvent
  /// with the given fields replaced by the non-null parameter values.
}

/// @nodoc
abstract class _$$LoadVideosImplCopyWith<$Res> {
  factory _$$LoadVideosImplCopyWith(
    _$LoadVideosImpl value,
    $Res Function(_$LoadVideosImpl) then,
  ) = __$$LoadVideosImplCopyWithImpl<$Res>;
}

/// @nodoc
class __$$LoadVideosImplCopyWithImpl<$Res>
    extends _$VideosEventCopyWithImpl<$Res, _$LoadVideosImpl>
    implements _$$LoadVideosImplCopyWith<$Res> {
  __$$LoadVideosImplCopyWithImpl(
    _$LoadVideosImpl _value,
    $Res Function(_$LoadVideosImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of VideosEvent
  /// with the given fields replaced by the non-null parameter values.
}

/// @nodoc

class _$LoadVideosImpl implements LoadVideos {
  const _$LoadVideosImpl();

  @override
  String toString() {
    return 'VideosEvent.loadVideos()';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType && other is _$LoadVideosImpl);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() loadVideos,
    required TResult Function() refreshVideos,
  }) {
    return loadVideos();
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? loadVideos,
    TResult? Function()? refreshVideos,
  }) {
    return loadVideos?.call();
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? loadVideos,
    TResult Function()? refreshVideos,
    required TResult orElse(),
  }) {
    if (loadVideos != null) {
      return loadVideos();
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(LoadVideos value) loadVideos,
    required TResult Function(RefreshVideos value) refreshVideos,
  }) {
    return loadVideos(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(LoadVideos value)? loadVideos,
    TResult? Function(RefreshVideos value)? refreshVideos,
  }) {
    return loadVideos?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(LoadVideos value)? loadVideos,
    TResult Function(RefreshVideos value)? refreshVideos,
    required TResult orElse(),
  }) {
    if (loadVideos != null) {
      return loadVideos(this);
    }
    return orElse();
  }
}

abstract class LoadVideos implements VideosEvent {
  const factory LoadVideos() = _$LoadVideosImpl;
}

/// @nodoc
abstract class _$$RefreshVideosImplCopyWith<$Res> {
  factory _$$RefreshVideosImplCopyWith(
    _$RefreshVideosImpl value,
    $Res Function(_$RefreshVideosImpl) then,
  ) = __$$RefreshVideosImplCopyWithImpl<$Res>;
}

/// @nodoc
class __$$RefreshVideosImplCopyWithImpl<$Res>
    extends _$VideosEventCopyWithImpl<$Res, _$RefreshVideosImpl>
    implements _$$RefreshVideosImplCopyWith<$Res> {
  __$$RefreshVideosImplCopyWithImpl(
    _$RefreshVideosImpl _value,
    $Res Function(_$RefreshVideosImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of VideosEvent
  /// with the given fields replaced by the non-null parameter values.
}

/// @nodoc

class _$RefreshVideosImpl implements RefreshVideos {
  const _$RefreshVideosImpl();

  @override
  String toString() {
    return 'VideosEvent.refreshVideos()';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType && other is _$RefreshVideosImpl);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() loadVideos,
    required TResult Function() refreshVideos,
  }) {
    return refreshVideos();
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? loadVideos,
    TResult? Function()? refreshVideos,
  }) {
    return refreshVideos?.call();
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? loadVideos,
    TResult Function()? refreshVideos,
    required TResult orElse(),
  }) {
    if (refreshVideos != null) {
      return refreshVideos();
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(LoadVideos value) loadVideos,
    required TResult Function(RefreshVideos value) refreshVideos,
  }) {
    return refreshVideos(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(LoadVideos value)? loadVideos,
    TResult? Function(RefreshVideos value)? refreshVideos,
  }) {
    return refreshVideos?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(LoadVideos value)? loadVideos,
    TResult Function(RefreshVideos value)? refreshVideos,
    required TResult orElse(),
  }) {
    if (refreshVideos != null) {
      return refreshVideos(this);
    }
    return orElse();
  }
}

abstract class RefreshVideos implements VideosEvent {
  const factory RefreshVideos() = _$RefreshVideosImpl;
}
