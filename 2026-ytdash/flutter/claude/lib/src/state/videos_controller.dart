import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/video_repository.dart';
import '../data/youtube_api.dart';
import '../domain/video.dart';
import '../domain/video_query.dart';
import 'providers.dart';

enum VideosStatus { loading, content, empty, error }

/// Observable view-state for the video list (constitution §1.3): loading /
/// content / empty / error, plus the full list (single source of truth) and a
/// derived visible list after applying the current [VideoQuery].
class VideosState {
  const VideosState({
    this.status = VideosStatus.loading,
    this.all = const [],
    this.visible = const [],
    this.query = const VideoQuery(),
    this.fromCache = false,
    this.errorMessage,
  });

  final VideosStatus status;
  final List<Video> all;
  final List<Video> visible;
  final VideoQuery query;
  final bool fromCache;
  final String? errorMessage;

  /// Total number of loaded videos across all channels (the `video_count`).
  int get totalCount => all.length;

  /// Videos that have a location, for the map screen.
  List<Video> get located => all.where((v) => v.hasLocation).toList();

  VideosState copyWith({
    VideosStatus? status,
    List<Video>? all,
    List<Video>? visible,
    VideoQuery? query,
    bool? fromCache,
    String? errorMessage,
  }) =>
      VideosState(
        status: status ?? this.status,
        all: all ?? this.all,
        visible: visible ?? this.visible,
        query: query ?? this.query,
        fromCache: fromCache ?? this.fromCache,
        errorMessage: errorMessage,
      );
}

class VideosController extends Notifier<VideosState> {
  @override
  VideosState build() => const VideosState();

  VideoRepository get _repo => ref.read(videoRepositoryProvider);

  Future<void> load() async {
    state = state.copyWith(status: VideosStatus.loading, errorMessage: null);
    try {
      final result = await _repo.refresh();
      _emit(result.videos, fromCache: result.fromCache, query: state.query);
    } on ApiException {
      // No fresh data and no cache to fall back to.
      state = state.copyWith(
        status: VideosStatus.error,
        errorMessage: 'Could not load videos. Check your connection and retry.',
      );
    }
  }

  Future<void> refresh() => load();

  void applyQuery(VideoQuery query) {
    _emit(state.all, fromCache: state.fromCache, query: query);
  }

  void setCategoryFilter(String? category) =>
      applyQuery(state.query.copyWith(categoryFilter: category));

  void setSort(SortField field, SortDirection direction) => applyQuery(
        state.query.copyWith(sortField: field, sortDirection: direction),
      );

  void _emit(List<Video> all, {required bool fromCache, required VideoQuery query}) {
    final visible = query.apply(all);
    state = VideosState(
      status: all.isEmpty ? VideosStatus.empty : VideosStatus.content,
      all: all,
      visible: visible,
      query: query,
      fromCache: fromCache,
    );
  }
}
