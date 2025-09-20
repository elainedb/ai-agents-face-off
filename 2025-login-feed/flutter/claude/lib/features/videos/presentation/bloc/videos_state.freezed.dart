// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'videos_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

/// @nodoc
mixin _$VideosState {
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() initial,
    required TResult Function() loading,
    required TResult Function(
      List<Video> videos,
      List<Video> filteredVideos,
      String? selectedChannel,
      String? selectedCountry,
      SortBy sortBy,
      SortOrder sortOrder,
      bool isRefreshing,
    )
    loaded,
    required TResult Function(String message) error,
  }) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? initial,
    TResult? Function()? loading,
    TResult? Function(
      List<Video> videos,
      List<Video> filteredVideos,
      String? selectedChannel,
      String? selectedCountry,
      SortBy sortBy,
      SortOrder sortOrder,
      bool isRefreshing,
    )?
    loaded,
    TResult? Function(String message)? error,
  }) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? initial,
    TResult Function()? loading,
    TResult Function(
      List<Video> videos,
      List<Video> filteredVideos,
      String? selectedChannel,
      String? selectedCountry,
      SortBy sortBy,
      SortOrder sortOrder,
      bool isRefreshing,
    )?
    loaded,
    TResult Function(String message)? error,
    required TResult orElse(),
  }) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(VideosInitial value) initial,
    required TResult Function(VideosLoading value) loading,
    required TResult Function(VideosLoaded value) loaded,
    required TResult Function(VideosError value) error,
  }) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(VideosInitial value)? initial,
    TResult? Function(VideosLoading value)? loading,
    TResult? Function(VideosLoaded value)? loaded,
    TResult? Function(VideosError value)? error,
  }) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(VideosInitial value)? initial,
    TResult Function(VideosLoading value)? loading,
    TResult Function(VideosLoaded value)? loaded,
    TResult Function(VideosError value)? error,
    required TResult orElse(),
  }) => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $VideosStateCopyWith<$Res> {
  factory $VideosStateCopyWith(
    VideosState value,
    $Res Function(VideosState) then,
  ) = _$VideosStateCopyWithImpl<$Res, VideosState>;
}

/// @nodoc
class _$VideosStateCopyWithImpl<$Res, $Val extends VideosState>
    implements $VideosStateCopyWith<$Res> {
  _$VideosStateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of VideosState
  /// with the given fields replaced by the non-null parameter values.
}

/// @nodoc
abstract class _$$VideosInitialImplCopyWith<$Res> {
  factory _$$VideosInitialImplCopyWith(
    _$VideosInitialImpl value,
    $Res Function(_$VideosInitialImpl) then,
  ) = __$$VideosInitialImplCopyWithImpl<$Res>;
}

/// @nodoc
class __$$VideosInitialImplCopyWithImpl<$Res>
    extends _$VideosStateCopyWithImpl<$Res, _$VideosInitialImpl>
    implements _$$VideosInitialImplCopyWith<$Res> {
  __$$VideosInitialImplCopyWithImpl(
    _$VideosInitialImpl _value,
    $Res Function(_$VideosInitialImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of VideosState
  /// with the given fields replaced by the non-null parameter values.
}

/// @nodoc

class _$VideosInitialImpl implements VideosInitial {
  const _$VideosInitialImpl();

  @override
  String toString() {
    return 'VideosState.initial()';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType && other is _$VideosInitialImpl);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() initial,
    required TResult Function() loading,
    required TResult Function(
      List<Video> videos,
      List<Video> filteredVideos,
      String? selectedChannel,
      String? selectedCountry,
      SortBy sortBy,
      SortOrder sortOrder,
      bool isRefreshing,
    )
    loaded,
    required TResult Function(String message) error,
  }) {
    return initial();
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? initial,
    TResult? Function()? loading,
    TResult? Function(
      List<Video> videos,
      List<Video> filteredVideos,
      String? selectedChannel,
      String? selectedCountry,
      SortBy sortBy,
      SortOrder sortOrder,
      bool isRefreshing,
    )?
    loaded,
    TResult? Function(String message)? error,
  }) {
    return initial?.call();
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? initial,
    TResult Function()? loading,
    TResult Function(
      List<Video> videos,
      List<Video> filteredVideos,
      String? selectedChannel,
      String? selectedCountry,
      SortBy sortBy,
      SortOrder sortOrder,
      bool isRefreshing,
    )?
    loaded,
    TResult Function(String message)? error,
    required TResult orElse(),
  }) {
    if (initial != null) {
      return initial();
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(VideosInitial value) initial,
    required TResult Function(VideosLoading value) loading,
    required TResult Function(VideosLoaded value) loaded,
    required TResult Function(VideosError value) error,
  }) {
    return initial(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(VideosInitial value)? initial,
    TResult? Function(VideosLoading value)? loading,
    TResult? Function(VideosLoaded value)? loaded,
    TResult? Function(VideosError value)? error,
  }) {
    return initial?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(VideosInitial value)? initial,
    TResult Function(VideosLoading value)? loading,
    TResult Function(VideosLoaded value)? loaded,
    TResult Function(VideosError value)? error,
    required TResult orElse(),
  }) {
    if (initial != null) {
      return initial(this);
    }
    return orElse();
  }
}

abstract class VideosInitial implements VideosState {
  const factory VideosInitial() = _$VideosInitialImpl;
}

/// @nodoc
abstract class _$$VideosLoadingImplCopyWith<$Res> {
  factory _$$VideosLoadingImplCopyWith(
    _$VideosLoadingImpl value,
    $Res Function(_$VideosLoadingImpl) then,
  ) = __$$VideosLoadingImplCopyWithImpl<$Res>;
}

/// @nodoc
class __$$VideosLoadingImplCopyWithImpl<$Res>
    extends _$VideosStateCopyWithImpl<$Res, _$VideosLoadingImpl>
    implements _$$VideosLoadingImplCopyWith<$Res> {
  __$$VideosLoadingImplCopyWithImpl(
    _$VideosLoadingImpl _value,
    $Res Function(_$VideosLoadingImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of VideosState
  /// with the given fields replaced by the non-null parameter values.
}

/// @nodoc

class _$VideosLoadingImpl implements VideosLoading {
  const _$VideosLoadingImpl();

  @override
  String toString() {
    return 'VideosState.loading()';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType && other is _$VideosLoadingImpl);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() initial,
    required TResult Function() loading,
    required TResult Function(
      List<Video> videos,
      List<Video> filteredVideos,
      String? selectedChannel,
      String? selectedCountry,
      SortBy sortBy,
      SortOrder sortOrder,
      bool isRefreshing,
    )
    loaded,
    required TResult Function(String message) error,
  }) {
    return loading();
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? initial,
    TResult? Function()? loading,
    TResult? Function(
      List<Video> videos,
      List<Video> filteredVideos,
      String? selectedChannel,
      String? selectedCountry,
      SortBy sortBy,
      SortOrder sortOrder,
      bool isRefreshing,
    )?
    loaded,
    TResult? Function(String message)? error,
  }) {
    return loading?.call();
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? initial,
    TResult Function()? loading,
    TResult Function(
      List<Video> videos,
      List<Video> filteredVideos,
      String? selectedChannel,
      String? selectedCountry,
      SortBy sortBy,
      SortOrder sortOrder,
      bool isRefreshing,
    )?
    loaded,
    TResult Function(String message)? error,
    required TResult orElse(),
  }) {
    if (loading != null) {
      return loading();
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(VideosInitial value) initial,
    required TResult Function(VideosLoading value) loading,
    required TResult Function(VideosLoaded value) loaded,
    required TResult Function(VideosError value) error,
  }) {
    return loading(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(VideosInitial value)? initial,
    TResult? Function(VideosLoading value)? loading,
    TResult? Function(VideosLoaded value)? loaded,
    TResult? Function(VideosError value)? error,
  }) {
    return loading?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(VideosInitial value)? initial,
    TResult Function(VideosLoading value)? loading,
    TResult Function(VideosLoaded value)? loaded,
    TResult Function(VideosError value)? error,
    required TResult orElse(),
  }) {
    if (loading != null) {
      return loading(this);
    }
    return orElse();
  }
}

abstract class VideosLoading implements VideosState {
  const factory VideosLoading() = _$VideosLoadingImpl;
}

/// @nodoc
abstract class _$$VideosLoadedImplCopyWith<$Res> {
  factory _$$VideosLoadedImplCopyWith(
    _$VideosLoadedImpl value,
    $Res Function(_$VideosLoadedImpl) then,
  ) = __$$VideosLoadedImplCopyWithImpl<$Res>;
  @useResult
  $Res call({
    List<Video> videos,
    List<Video> filteredVideos,
    String? selectedChannel,
    String? selectedCountry,
    SortBy sortBy,
    SortOrder sortOrder,
    bool isRefreshing,
  });
}

/// @nodoc
class __$$VideosLoadedImplCopyWithImpl<$Res>
    extends _$VideosStateCopyWithImpl<$Res, _$VideosLoadedImpl>
    implements _$$VideosLoadedImplCopyWith<$Res> {
  __$$VideosLoadedImplCopyWithImpl(
    _$VideosLoadedImpl _value,
    $Res Function(_$VideosLoadedImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of VideosState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? videos = null,
    Object? filteredVideos = null,
    Object? selectedChannel = freezed,
    Object? selectedCountry = freezed,
    Object? sortBy = null,
    Object? sortOrder = null,
    Object? isRefreshing = null,
  }) {
    return _then(
      _$VideosLoadedImpl(
        videos: null == videos
            ? _value._videos
            : videos // ignore: cast_nullable_to_non_nullable
                  as List<Video>,
        filteredVideos: null == filteredVideos
            ? _value._filteredVideos
            : filteredVideos // ignore: cast_nullable_to_non_nullable
                  as List<Video>,
        selectedChannel: freezed == selectedChannel
            ? _value.selectedChannel
            : selectedChannel // ignore: cast_nullable_to_non_nullable
                  as String?,
        selectedCountry: freezed == selectedCountry
            ? _value.selectedCountry
            : selectedCountry // ignore: cast_nullable_to_non_nullable
                  as String?,
        sortBy: null == sortBy
            ? _value.sortBy
            : sortBy // ignore: cast_nullable_to_non_nullable
                  as SortBy,
        sortOrder: null == sortOrder
            ? _value.sortOrder
            : sortOrder // ignore: cast_nullable_to_non_nullable
                  as SortOrder,
        isRefreshing: null == isRefreshing
            ? _value.isRefreshing
            : isRefreshing // ignore: cast_nullable_to_non_nullable
                  as bool,
      ),
    );
  }
}

/// @nodoc

class _$VideosLoadedImpl implements VideosLoaded {
  const _$VideosLoadedImpl({
    required final List<Video> videos,
    required final List<Video> filteredVideos,
    this.selectedChannel,
    this.selectedCountry,
    this.sortBy = SortBy.publishedDate,
    this.sortOrder = SortOrder.descending,
    this.isRefreshing = false,
  }) : _videos = videos,
       _filteredVideos = filteredVideos;

  final List<Video> _videos;
  @override
  List<Video> get videos {
    if (_videos is EqualUnmodifiableListView) return _videos;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_videos);
  }

  final List<Video> _filteredVideos;
  @override
  List<Video> get filteredVideos {
    if (_filteredVideos is EqualUnmodifiableListView) return _filteredVideos;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_filteredVideos);
  }

  @override
  final String? selectedChannel;
  @override
  final String? selectedCountry;
  @override
  @JsonKey()
  final SortBy sortBy;
  @override
  @JsonKey()
  final SortOrder sortOrder;
  @override
  @JsonKey()
  final bool isRefreshing;

  @override
  String toString() {
    return 'VideosState.loaded(videos: $videos, filteredVideos: $filteredVideos, selectedChannel: $selectedChannel, selectedCountry: $selectedCountry, sortBy: $sortBy, sortOrder: $sortOrder, isRefreshing: $isRefreshing)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$VideosLoadedImpl &&
            const DeepCollectionEquality().equals(other._videos, _videos) &&
            const DeepCollectionEquality().equals(
              other._filteredVideos,
              _filteredVideos,
            ) &&
            (identical(other.selectedChannel, selectedChannel) ||
                other.selectedChannel == selectedChannel) &&
            (identical(other.selectedCountry, selectedCountry) ||
                other.selectedCountry == selectedCountry) &&
            (identical(other.sortBy, sortBy) || other.sortBy == sortBy) &&
            (identical(other.sortOrder, sortOrder) ||
                other.sortOrder == sortOrder) &&
            (identical(other.isRefreshing, isRefreshing) ||
                other.isRefreshing == isRefreshing));
  }

  @override
  int get hashCode => Object.hash(
    runtimeType,
    const DeepCollectionEquality().hash(_videos),
    const DeepCollectionEquality().hash(_filteredVideos),
    selectedChannel,
    selectedCountry,
    sortBy,
    sortOrder,
    isRefreshing,
  );

  /// Create a copy of VideosState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$VideosLoadedImplCopyWith<_$VideosLoadedImpl> get copyWith =>
      __$$VideosLoadedImplCopyWithImpl<_$VideosLoadedImpl>(this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() initial,
    required TResult Function() loading,
    required TResult Function(
      List<Video> videos,
      List<Video> filteredVideos,
      String? selectedChannel,
      String? selectedCountry,
      SortBy sortBy,
      SortOrder sortOrder,
      bool isRefreshing,
    )
    loaded,
    required TResult Function(String message) error,
  }) {
    return loaded(
      videos,
      filteredVideos,
      selectedChannel,
      selectedCountry,
      sortBy,
      sortOrder,
      isRefreshing,
    );
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? initial,
    TResult? Function()? loading,
    TResult? Function(
      List<Video> videos,
      List<Video> filteredVideos,
      String? selectedChannel,
      String? selectedCountry,
      SortBy sortBy,
      SortOrder sortOrder,
      bool isRefreshing,
    )?
    loaded,
    TResult? Function(String message)? error,
  }) {
    return loaded?.call(
      videos,
      filteredVideos,
      selectedChannel,
      selectedCountry,
      sortBy,
      sortOrder,
      isRefreshing,
    );
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? initial,
    TResult Function()? loading,
    TResult Function(
      List<Video> videos,
      List<Video> filteredVideos,
      String? selectedChannel,
      String? selectedCountry,
      SortBy sortBy,
      SortOrder sortOrder,
      bool isRefreshing,
    )?
    loaded,
    TResult Function(String message)? error,
    required TResult orElse(),
  }) {
    if (loaded != null) {
      return loaded(
        videos,
        filteredVideos,
        selectedChannel,
        selectedCountry,
        sortBy,
        sortOrder,
        isRefreshing,
      );
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(VideosInitial value) initial,
    required TResult Function(VideosLoading value) loading,
    required TResult Function(VideosLoaded value) loaded,
    required TResult Function(VideosError value) error,
  }) {
    return loaded(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(VideosInitial value)? initial,
    TResult? Function(VideosLoading value)? loading,
    TResult? Function(VideosLoaded value)? loaded,
    TResult? Function(VideosError value)? error,
  }) {
    return loaded?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(VideosInitial value)? initial,
    TResult Function(VideosLoading value)? loading,
    TResult Function(VideosLoaded value)? loaded,
    TResult Function(VideosError value)? error,
    required TResult orElse(),
  }) {
    if (loaded != null) {
      return loaded(this);
    }
    return orElse();
  }
}

abstract class VideosLoaded implements VideosState {
  const factory VideosLoaded({
    required final List<Video> videos,
    required final List<Video> filteredVideos,
    final String? selectedChannel,
    final String? selectedCountry,
    final SortBy sortBy,
    final SortOrder sortOrder,
    final bool isRefreshing,
  }) = _$VideosLoadedImpl;

  List<Video> get videos;
  List<Video> get filteredVideos;
  String? get selectedChannel;
  String? get selectedCountry;
  SortBy get sortBy;
  SortOrder get sortOrder;
  bool get isRefreshing;

  /// Create a copy of VideosState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$VideosLoadedImplCopyWith<_$VideosLoadedImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$VideosErrorImplCopyWith<$Res> {
  factory _$$VideosErrorImplCopyWith(
    _$VideosErrorImpl value,
    $Res Function(_$VideosErrorImpl) then,
  ) = __$$VideosErrorImplCopyWithImpl<$Res>;
  @useResult
  $Res call({String message});
}

/// @nodoc
class __$$VideosErrorImplCopyWithImpl<$Res>
    extends _$VideosStateCopyWithImpl<$Res, _$VideosErrorImpl>
    implements _$$VideosErrorImplCopyWith<$Res> {
  __$$VideosErrorImplCopyWithImpl(
    _$VideosErrorImpl _value,
    $Res Function(_$VideosErrorImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of VideosState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? message = null}) {
    return _then(
      _$VideosErrorImpl(
        null == message
            ? _value.message
            : message // ignore: cast_nullable_to_non_nullable
                  as String,
      ),
    );
  }
}

/// @nodoc

class _$VideosErrorImpl implements VideosError {
  const _$VideosErrorImpl(this.message);

  @override
  final String message;

  @override
  String toString() {
    return 'VideosState.error(message: $message)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$VideosErrorImpl &&
            (identical(other.message, message) || other.message == message));
  }

  @override
  int get hashCode => Object.hash(runtimeType, message);

  /// Create a copy of VideosState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$VideosErrorImplCopyWith<_$VideosErrorImpl> get copyWith =>
      __$$VideosErrorImplCopyWithImpl<_$VideosErrorImpl>(this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() initial,
    required TResult Function() loading,
    required TResult Function(
      List<Video> videos,
      List<Video> filteredVideos,
      String? selectedChannel,
      String? selectedCountry,
      SortBy sortBy,
      SortOrder sortOrder,
      bool isRefreshing,
    )
    loaded,
    required TResult Function(String message) error,
  }) {
    return error(message);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? initial,
    TResult? Function()? loading,
    TResult? Function(
      List<Video> videos,
      List<Video> filteredVideos,
      String? selectedChannel,
      String? selectedCountry,
      SortBy sortBy,
      SortOrder sortOrder,
      bool isRefreshing,
    )?
    loaded,
    TResult? Function(String message)? error,
  }) {
    return error?.call(message);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? initial,
    TResult Function()? loading,
    TResult Function(
      List<Video> videos,
      List<Video> filteredVideos,
      String? selectedChannel,
      String? selectedCountry,
      SortBy sortBy,
      SortOrder sortOrder,
      bool isRefreshing,
    )?
    loaded,
    TResult Function(String message)? error,
    required TResult orElse(),
  }) {
    if (error != null) {
      return error(message);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(VideosInitial value) initial,
    required TResult Function(VideosLoading value) loading,
    required TResult Function(VideosLoaded value) loaded,
    required TResult Function(VideosError value) error,
  }) {
    return error(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(VideosInitial value)? initial,
    TResult? Function(VideosLoading value)? loading,
    TResult? Function(VideosLoaded value)? loaded,
    TResult? Function(VideosError value)? error,
  }) {
    return error?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(VideosInitial value)? initial,
    TResult Function(VideosLoading value)? loading,
    TResult Function(VideosLoaded value)? loaded,
    TResult Function(VideosError value)? error,
    required TResult orElse(),
  }) {
    if (error != null) {
      return error(this);
    }
    return orElse();
  }
}

abstract class VideosError implements VideosState {
  const factory VideosError(final String message) = _$VideosErrorImpl;

  String get message;

  /// Create a copy of VideosState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$VideosErrorImplCopyWith<_$VideosErrorImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
