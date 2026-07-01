import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/providers.dart';
import '../../data/video_repository.dart';
import '../../domain/models/video.dart';
import '../../domain/sorting_filtering.dart';
import 'home_view_state.dart';

class HomeViewModel extends Notifier<HomeViewState> {
  List<Video> _allVideos = const [];
  String? _filterCategory;
  SortOrder _sortOrder = SortOrder.dateDescending;

  String? get filterCategory => _filterCategory;
  SortOrder get sortOrder => _sortOrder;

  /// The full merged set, independent of the list's active filter — the map plots every
  /// located video regardless of what's currently filtered in the list.
  List<Video> get allVideos => _allVideos;

  @override
  HomeViewState build() {
    _load();
    return const HomeLoading();
  }

  Future<void> refresh() => _load();

  Future<void> _load() async {
    try {
      final repo = await ref.read(videoRepositoryProvider.future);

      final cached = await repo.readCached();
      if (cached.isNotEmpty) {
        _allVideos = cached;
        _publish();
      } else {
        state = const HomeLoading();
      }

      final result = await repo.refresh();
      switch (result) {
        case RefreshSucceeded(:final videos):
          _allVideos = videos;
          _publish();
        case RefreshFailedWithCache(:final cachedVideos):
          _allVideos = cachedVideos;
          _publish();
        case RefreshFailedNoCache(:final error):
          state = HomeError(error.toString());
      }
    } catch (e) {
      state = HomeError(e.toString());
    }
  }

  void setFilter(String? category) {
    _filterCategory = category;
    _publish();
  }

  void setSort(SortOrder order) {
    _sortOrder = order;
    _publish();
  }

  void _publish() {
    if (_allVideos.isEmpty) {
      state = const HomeEmpty();
      return;
    }
    final filtered = filterVideos(_allVideos, _filterCategory);
    final sorted = sortVideos(filtered, _sortOrder);
    state = HomeContent(
      totalCount: _allVideos.length,
      displayedVideos: sorted,
      filterCategory: _filterCategory,
      sortOrder: _sortOrder,
    );
  }
}

final homeViewModelProvider = NotifierProvider<HomeViewModel, HomeViewState>(
  HomeViewModel.new,
);
