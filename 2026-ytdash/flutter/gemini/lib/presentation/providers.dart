import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/youtube_api.dart';
import '../data/cache_repository.dart';
import '../domain/auth_repository.dart';
import '../domain/video_repository.dart';
import '../domain/models.dart';

final authRepositoryProvider = Provider((ref) => AuthRepository());
final cacheRepositoryProvider = Provider((ref) => CacheRepository());
final youtubeApiProvider = Provider((ref) => YouTubeApi());

final videoRepositoryProvider = Provider((ref) {
  return VideoRepository(
    ref.read(youtubeApiProvider),
    ref.read(cacheRepositoryProvider),
  );
});

final authStateProvider = StateProvider<bool>((ref) => false);
final authErrorProvider = StateProvider<String?>((ref) => null);

class VideoListState {
  final bool isLoading;
  final String? error;
  final List<Video> videos;
  final String? currentFilter; // category label
  final bool? sortDateDesc;

  VideoListState({
    this.isLoading = false,
    this.error,
    this.videos = const [],
    this.currentFilter,
    this.sortDateDesc,
  });

  VideoListState copyWith({
    bool? isLoading,
    String? error,
    List<Video>? videos,
    String? currentFilter,
    bool? sortDateDesc,
    bool clearFilter = false,
    bool clearError = false,
    bool clearSort = false,
  }) {
    return VideoListState(
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : (error ?? this.error),
      videos: videos ?? this.videos,
      currentFilter: clearFilter ? null : (currentFilter ?? this.currentFilter),
      sortDateDesc: clearSort ? null : (sortDateDesc ?? this.sortDateDesc),
    );
  }

  List<Video> get visibleVideos {
    var result = List<Video>.from(videos);
    if (currentFilter != null) {
      result = result.where((v) => v.category.toLowerCase() == currentFilter!.toLowerCase()).toList();
    }
    if (sortDateDesc != null) {
      result.sort((a, b) {
        if (sortDateDesc!) {
          return b.publishedAt.compareTo(a.publishedAt);
        } else {
          return a.publishedAt.compareTo(b.publishedAt);
        }
      });
    }
    return result;
  }
}

class VideoListNotifier extends StateNotifier<VideoListState> {
  final VideoRepository _repo;

  VideoListNotifier(this._repo) : super(VideoListState()) {
    load();
  }

  Future<void> load({bool force = false}) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final videos = await _repo.getVideos(forceRefresh: force);
      state = state.copyWith(isLoading: false, videos: videos);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  void setFilter(String? filter) {
    state = state.copyWith(
      currentFilter: filter,
      clearFilter: filter == null,
    );
  }

  void setSort({required bool dateDesc}) {
    state = state.copyWith(sortDateDesc: dateDesc);
  }
}

final videoListProvider = StateNotifierProvider<VideoListNotifier, VideoListState>((ref) {
  return VideoListNotifier(ref.read(videoRepositoryProvider));
});
