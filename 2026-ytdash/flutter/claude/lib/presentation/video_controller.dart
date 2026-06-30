import 'package:flutter/foundation.dart';

import '../core/result.dart';
import '../data/models/video.dart';
import '../data/video_repository.dart';
import '../domain/video_query.dart';

enum ViewState { loading, content, empty, error }

/// Holds the home-screen view-state (constitution §1.3). The full loaded set is the source of
/// truth; `visibleVideos` is the filtered+sorted projection the list renders.
class VideoController extends ChangeNotifier {
  VideoController({required this.repository});

  final VideoRepository repository;

  ViewState state = ViewState.loading;
  String? errorMessage;

  List<Video> _all = const [];
  String? filterCategory; // null == all
  // Default = API/aggregation order so the first row is deterministic (AC-LIST-03 → VIDEO_ID_1).
  SortOption sortOption = SortOption.none;

  List<Video> get allVideos => _all;
  int get totalCount => _all.length;

  List<Video> get visibleVideos =>
      VideoQuery.apply(_all, filterCategory, sortOption);

  List<Video> get locatedVideos =>
      _all.where((v) => v.hasLocation).toList(growable: false);

  List<String> get categories => VideoQuery.categoriesOf(_all);

  Future<void> load({bool forceRefresh = false}) async {
    if (_all.isEmpty) {
      state = ViewState.loading;
      notifyListeners();
    }
    final Result<List<Video>> result =
        await repository.getVideos(forceRefresh: forceRefresh);
    switch (result) {
      case Ok(value: final videos):
        _all = videos;
        state = videos.isEmpty ? ViewState.empty : ViewState.content;
        errorMessage = null;
      case Err(failure: final f):
        errorMessage = f.message;
        // Keep showing whatever we already have; only block with an error if we have nothing.
        state = _all.isEmpty ? ViewState.error : ViewState.content;
    }
    notifyListeners();
  }

  void setFilter(String? category) {
    filterCategory = category;
    notifyListeners();
  }

  void setSort(SortOption option) {
    sortOption = option;
    notifyListeners();
  }
}
