import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/ui_state.dart';
import '../../data/video_repository_impl.dart';
import '../../domain/entities/video.dart';
import '../../domain/filtering/video_filter.dart';
import '../../domain/repositories/video_repository.dart';
import '../../domain/sorting/video_sort.dart';

class HomeState {
  const HomeState({required this.videos, this.filterLabel, this.sortKey});

  final UiState<List<Video>> videos;
  final String? filterLabel;

  /// Null = natural load order (the order videos were fetched in — the fixture's first video,
  /// `VIDEO_ID_1`, must be first per spec.md §Data / AC-LIST-03, so no sort is applied until the
  /// user explicitly picks one from the sort sheet).
  final SortKey? sortKey;

  HomeState withVideos(UiState<List<Video>> v) =>
      HomeState(videos: v, filterLabel: filterLabel, sortKey: sortKey);

  HomeState withFilter(String? label) =>
      HomeState(videos: videos, filterLabel: label, sortKey: sortKey);

  HomeState withSort(SortKey key) =>
      HomeState(videos: videos, filterLabel: filterLabel, sortKey: key);

  /// The videos actually shown in `video_list` — filtered/sorted. `video_count` is derived
  /// separately from the raw loaded total, NOT this list (spec: count = total loaded).
  List<Video> get visible {
    if (videos is! UiContent<List<Video>>) return const [];
    final raw = (videos as UiContent<List<Video>>).data;
    final filtered = filterByCategory(raw, filterLabel);
    final key = sortKey;
    return key == null ? filtered : sortVideos(filtered, key);
  }

  int? get totalLoadedCount => videos is UiContent<List<Video>>
      ? (videos as UiContent<List<Video>>).data.length
      : null;

  List<String> get availableCategories {
    if (videos is! UiContent<List<Video>>) return const [];
    return distinctCategories((videos as UiContent<List<Video>>).data);
  }
}

/// Loads the cache instantly (if any) for a fast first paint, then refreshes from the network —
/// which replaces the cache on success or falls back to the stale cache on failure (constitution
/// §1.5 single source of truth; AC-CACHE-01).
class HomeController extends StateNotifier<HomeState> {
  HomeController(this._repo) : super(const HomeState(videos: UiLoading())) {
    _bootstrap();
  }

  final VideoRepository _repo;

  Future<void> _bootstrap() async {
    final cached = await _repo.cached();
    if (cached.isNotEmpty && mounted) {
      state = state.withVideos(UiContent(cached));
    }
    await refresh();
  }

  Future<void> refresh() async {
    if (state.videos is! UiContent<List<Video>>) {
      state = state.withVideos(const UiLoading());
    }
    final result = await _repo.refresh();
    if (!mounted) return;
    switch (result) {
      case VideoResultOk(:final videos):
        state = state.withVideos(
          videos.isEmpty ? const UiEmpty() : UiContent(videos),
        );
      case VideoResultError(:final message):
        // Stale-fallback: if we already have content on screen (e.g. from the cache bootstrap),
        // keep it visible rather than blocking with error_view.
        if (state.videos is! UiContent<List<Video>>) {
          state = state.withVideos(UiError(message));
        }
    }
  }

  void setFilter(String? label) => state = state.withFilter(label);

  void setSort(SortKey key) => state = state.withSort(key);
}

final homeControllerProvider = StateNotifierProvider<HomeController, HomeState>(
  (ref) => HomeController(ref.watch(videoRepositoryProvider)),
);
