import '../../domain/models/video.dart';
import '../../domain/sorting_filtering.dart';

/// Unidirectional, observable view-state for the home screen (constitution §1.3):
/// loading / content / empty / error, nothing else.
sealed class HomeViewState {
  const HomeViewState();
}

class HomeLoading extends HomeViewState {
  const HomeLoading();
}

/// The load succeeded but there are zero videos across every configured channel.
class HomeEmpty extends HomeViewState {
  const HomeEmpty();
}

class HomeContent extends HomeViewState {
  const HomeContent({
    required this.totalCount,
    required this.displayedVideos,
    required this.filterCategory,
    required this.sortOrder,
  });

  /// Total videos loaded across all channels (constitution §3 `video_count`), independent of
  /// any active filter.
  final int totalCount;
  final List<Video> displayedVideos;
  final String? filterCategory;
  final SortOrder sortOrder;
}

class HomeError extends HomeViewState {
  const HomeError(this.message);
  final String message;
}
