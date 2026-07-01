import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/models/video.dart';
import '../data/repository/video_repository.dart';
import '../domain/filtering/video_filter.dart';
import '../domain/sorting/video_sort.dart';
import 'providers.dart';

enum HomeStatus { loading, content, empty, error }

@immutable
class HomeState {
  const HomeState({
    required this.status,
    this.allVideos = const [],
    this.displayedVideos = const [],
    this.filterCategory,
    this.sortOption,
    this.errorMessage,
  });

  final HomeStatus status;
  final List<Video> allVideos;
  final List<Video> displayedVideos;
  final String? filterCategory;
  // `null` = natural fetch order (constitution: no business logic hidden from the user) — the list
  // is not implicitly sorted until the user picks a sort option (AC-LIST-03 relies on the first
  // fetched video staying first until then).
  final SortOption? sortOption;
  final String? errorMessage;

  static const initial = HomeState(status: HomeStatus.loading);

  List<String> get availableCategories =>
      allVideos.map((v) => v.category).toSet().toList()..sort();

  HomeState _copyWith({
    HomeStatus? status,
    List<Video>? allVideos,
    List<Video>? displayedVideos,
    String? filterCategory,
    bool clearFilterCategory = false,
    SortOption? sortOption,
    String? errorMessage,
  }) => HomeState(
    status: status ?? this.status,
    allVideos: allVideos ?? this.allVideos,
    displayedVideos: displayedVideos ?? this.displayedVideos,
    filterCategory: clearFilterCategory
        ? null
        : (filterCategory ?? this.filterCategory),
    sortOption: sortOption ?? this.sortOption,
    errorMessage: errorMessage,
  );
}

/// Screens render from this explicit, observable view-state (constitution §1.3); filter/sort logic
/// itself lives in `domain/` as pure functions this controller merely invokes.
class HomeController extends Notifier<HomeState> {
  VideoRepository get repository => ref.read(videoRepositoryProvider);

  @override
  HomeState build() {
    // Kick off the initial load after this synchronous build() returns (state isn't readable yet
    // while build() is still running).
    Future(load);
    return HomeState.initial;
  }

  List<Video> _applyView(
    List<Video> all, {
    String? filterCategory,
    SortOption? sortOption,
  }) {
    final filtered = filterByCategory(all, filterCategory);
    return sortOption == null ? filtered : sortVideos(filtered, sortOption);
  }

  Future<void> load() async {
    state = state._copyWith(status: HomeStatus.loading);
    try {
      final videos = await repository.fetchVideos();
      final displayed = _applyView(
        videos,
        filterCategory: state.filterCategory,
        sortOption: state.sortOption,
      );
      state = state._copyWith(
        status: displayed.isEmpty ? HomeStatus.empty : HomeStatus.content,
        allVideos: videos,
        displayedVideos: displayed,
      );
    } catch (e) {
      state = state._copyWith(
        status: HomeStatus.error,
        errorMessage: 'Could not load videos: $e',
      );
    }
  }

  Future<void> refresh() => load();

  void applyFilter(String? category) {
    final displayed = _applyView(
      state.allVideos,
      filterCategory: category,
      sortOption: state.sortOption,
    );
    state = state._copyWith(
      filterCategory: category,
      clearFilterCategory: category == null,
      displayedVideos: displayed,
      status: displayed.isEmpty ? HomeStatus.empty : HomeStatus.content,
    );
  }

  void applySort(SortOption option) {
    final displayed = _applyView(
      state.allVideos,
      filterCategory: state.filterCategory,
      sortOption: option,
    );
    state = state._copyWith(sortOption: option, displayedVideos: displayed);
  }
}
